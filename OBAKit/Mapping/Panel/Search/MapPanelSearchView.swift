//
//  MapPanelSearchView.swift
//  OBAKit
//
//  Created by Alan Chu on 12/10/22.
//

import SwiftUI
import OBAKitCore

@MainActor
class MapPanelSearchProvider: ObservableObject {
    var quickSearchOptions: [IdentifableQuickSearchOption] = [
        IdentifableQuickSearchOption("route", QuickSearchRoute.self),
        IdentifableQuickSearchOption("address", QuickSearchAddress.self)
    ]

    var application: Application?
    init(_ application: Application?) {
        self.application = application
    }

    @Published var searchQuery: String = "" {
        didSet {
            searchResult = nil
        }
    }
    @Published var recentStops: [String] = []

    typealias SearchResultType = Result<(any QuickSearchResults), Error>
    @Published var searchResult: SearchResultType?

    @Published private(set) var isPerformingSearch: Bool = false

    func performSearch(optionID: String) async {
        let searchOption = quickSearchOptions.first { option in
            if case let MapPanelSearchIdentifier.quickSearch(id) = option.id {
                return id == optionID
            } else {
                return false
            }
        }

        guard let searchOption else {
            return
        }

        self.isPerformingSearch = true

        defer {
            self.isPerformingSearch = false
        }

        guard let application else {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            searchResult = .failure(NSError(domain: "asdf", code: 418, userInfo: [
                NSLocalizedDescriptionKey: "hi, there is no application. bye."
            ]))
            return
        }

        let search = searchOption.type.init(application: application)
        do {
            let results = try await search.performSearch(query: searchQuery)
            self.searchResult = .success(results)
        } catch {
            self.searchResult = .failure(error)
        }
    }
}

struct IdentifableQuickSearchOption: Identifiable {
    let id: MapPanelSearchIdentifier
    let type: any QuickSearchOption.Type

    init(_ id: String, _ type: any QuickSearchOption.Type) {
        self.id = .quickSearch(id)
        self.type = type
    }
}

enum MapPanelSearchIdentifier: Hashable {
    case quickSearch(String)
    case recentStop(StopID)
}

struct MapPanelSearchView: View {
    @ObservedObject var provider: MapPanelSearchProvider

    @State var selectedItem: MapPanelSearchIdentifier?

    var body: some View {
        List(selection: $selectedItem) {
            if provider.isPerformingSearch {
                ProgressView("Loading...")
            } else if let searchResult = provider.searchResult {
                results(searchResult)
            } else {
                if provider.searchQuery.isEmpty {
                    emptyStateView
                } else {
                    quickSearchSelection
                }
            }
        }
        .listStyle(.plain)
        .removeListBackground()
        .task(id: selectedItem) {
            guard let selectedItem else {
                return
            }

            switch selectedItem {
            case .quickSearch(let quickSearchID):
                await provider.performSearch(optionID: quickSearchID)
                print("quick search: \(quickSearchID)")
            case .recentStop(let stopID):
                print("recent stop: \(stopID)")
            }

            self.selectedItem = nil
        }
    }

    // MARK: - Displaying results
    @ViewBuilder
    private func results(_ response: MapPanelSearchProvider.SearchResultType) -> some View {
        switch response {
        case .failure(let error):
            Text(error.localizedDescription)
        case .success(let results):
            if results.results.isEmpty {
                Text("No results")
            } else {
                Text("\(results.results.count) results")
            }
        }
    }

    // MARK: - Not-Empty State
    private var quickSearchSelection: some View {
        Section {
            ForEach(provider.quickSearchOptions) { option in
                quickSearchItem(option.type.localizedTitle,
                                systemImage: option.type.systemImage)
            }

//            quickSearchItem("Route", systemImage: "chart.xyaxis.line")
//            quickSearchItem("Address", systemImage: "mappin")
//            quickSearchItem("Stop", systemImage: "square.and.arrow.down")
//            quickSearchItem("Vehicle", systemImage: "bus")
        } header: {
            Text("Quick Search")
        }
    }

    @ViewBuilder
    private func quickSearchItem(_ searchType: String, systemImage: String) -> some View {
        Label {
            Text(searchType) +
            Text(": ") +
            Text(provider.searchQuery)
                    .fontWeight(.bold)
                    .accessibilityLabel(searchType)
        } icon: {
            Image(systemName: systemImage)
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(alignment: .center) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle)
            Text("Search")
                .font(.title)
            Text("Type in an address, route name, stop number, or vehicle here to search")
                .font(.headline)
        }

        .multilineTextAlignment(.center)
        .padding()
    }
}

// MARK: - Previews -

#if DEBUG && targetEnvironment(simulator)

fileprivate struct TestSearchQueryPreview: View {
    @ObservedObject var provider = MapPanelSearchProvider(nil)

    var body: some View {
        VStack {
            TextField("Search", text: $provider.searchQuery)
                .disabled(provider.isPerformingSearch)
            MapPanelSearchView(provider: provider)
        }
    }
}

struct MapPanelSearchView_Previews: PreviewProvider {
    static var previews: some View {
        TestSearchQueryPreview()
    }
}

#endif

//
//  MapPanelSearchView.swift
//  OBAKit
//
//  Created by Alan Chu on 12/10/22.
//

import SwiftUI

class MapPanelSearchProvider: ObservableObject {
    var quickSearchOptions: [IdentifableQuickSearchOption] = [
        IdentifableQuickSearchOption("route", QuickSearchRoute.self)
    ]

    @Published var searchQuery: String = ""
    @Published var recentStops: [String] = []

    @Published var searchResult: SearchResponse?
}

struct MapPanelSearchView: View {
    @ObservedObject var provider: MapPanelSearchProvider

    @State var performingSearch: Bool = false

    var body: some View {
        List {
            if let searchResult = provider.searchResult {
                results(searchResult)
            } else {
                if provider.searchQuery.isEmpty {
                    emptyStateView
                } else {
                    quickSearchSelection
                }
            }
        }
        .task(id: performingSearch) {
            guard performingSearch else { return }
        }
    }

    // MARK: - Displaying results
    @ViewBuilder
    private func results(_ response: SearchResponse) -> some View {
        Text("\(response.results.count) results")
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
    @ObservedObject var provider = MapPanelSearchProvider()

    var body: some View {
        VStack {
            TextField("Search", text: $provider.searchQuery)
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

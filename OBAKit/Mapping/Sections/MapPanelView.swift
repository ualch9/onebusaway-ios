//
//  MapPanelView.swift
//  OBAKit
//
//  Created by Alan Chu on 10/10/22.
//

import SwiftUI
import OBAKitCore

protocol MapPanelViewDelegate: AnyObject {
    func didSelect(alert alertID: String)
    func didSelect(stop stopID: Stop.ID)
}

protocol MapPanelViewProvider: ObservableObject {
    var alerts: [AgencyAlertViewModel] { get set }
    var nearbyStops: [StopViewModel] { get set }
    var recentStops: [StopViewModel] { get set }
    var bookmarks: [StopViewModel] { get set }
}

struct AgencyAlertViewModel: Identifiable, Hashable {
    let id: MapPanelViewIdentifier
    let title: String
    let agencyName: String?

    init(id: String = UUID().uuidString, title: String, agencyName: String?) {
        self.id = .alert(id)
        self.title = title
        self.agencyName = agencyName
    }

    init(_ agencyAlert: AgencyAlert) {
        self.id = .alert(agencyAlert.id)
        self.title = agencyAlert.title(forLocale: .current) ?? ""
        self.agencyName = agencyAlert.affectedAgencyName
    }
}

extension StopViewModel {
    var panelViewIdentifier: MapPanelViewIdentifier {
        return .stop(id)
    }
}

enum MapPanelViewIdentifier: Hashable {
    case stop(Stop.ID)
    case alert(String)
}

struct MapPanelView<ProviderType: MapPanelViewProvider>: View {
    @ObservedObject public var provider: ProviderType
    public weak var delegate: MapPanelViewDelegate?

    @State fileprivate var selectedItem: MapPanelViewIdentifier?

    var body: some View {
        List(selection: $selectedItem) {
            if provider.alerts.isEmpty == false {
                Section("Agency Alerts") {
                    ForEach(provider.alerts, id: \.id, content: AgencyAlertView.init)
                }
            }

            Section("Recent Stops") {
                ForEach(provider.recentStops, id: \.panelViewIdentifier, content: StopView.init)
            }

            Section("Nearby Stops") {
                ForEach(provider.nearbyStops, id: \.panelViewIdentifier, content: StopView.init)
            }
        }
        
        .onAppear {
            self.selectedItem = nil
        }
        .environment(\.editMode, .constant(.active))    // workaround for removing selection background when `selectedItem = nil`.
        .task(id: selectedItem) {
            guard let selectedItem, let delegate else { return }

            switch selectedItem {
            case .stop(let id):
                await MainActor.run {
                    delegate.didSelect(stop: id)
                }
            case .alert(let id):
                await MainActor.run {
                    delegate.didSelect(alert: id)
                }
            }
        }
    }
}

extension MapPanelView {
    struct StopView: View {
        @State var stop: StopViewModel

        var body: some View {
            HStack {
                Image(uiImage: Icons.transportIcon(from: stop.routeType))
                    .resizable()
                    .frame(maxWidth: 18, maxHeight: 18)
                    .foregroundColor(Color.primary)
                VStack(alignment: .leading) {
                    Text(stop.name)
                    if let subtitle = stop.subtitle {
                        Text(subtitle)
                    }
                }

                Spacer()

                Image(systemName: "chevron.forward")
                    .foregroundColor(.secondary)
            }
        }
    }

    struct AgencyAlertView: View {
        @State var alert: AgencyAlertViewModel

        var body: some View {
            HStack(alignment: .center) {
                Image(systemName: "exclamationmark.circle")

                VStack(alignment: .leading) {
                    Text(alert.title)
                    if let agency = alert.agencyName {
                        Text(agency)
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
            }
        }
    }
}

struct MapPanelView_Previews: PreviewProvider {
    fileprivate class Previews_DebugProvider: MapPanelViewProvider {
        @Published var nearbyStops: [StopViewModel] = [
            .init(name: "3rd Ave & 500th Place or something", routeType: .bus),
            .init(name: "4th Ave & 501st Place or something", routeType: .ferry),
            .init(name: "5th Ave & 500th Place or something", routeType: .rail),
            .init(name: "6th Ave & 500th Place or something", routeType: .lightRail)
        ]

        @Published var recentStops: [StopViewModel] = []
        @Published var alerts: [AgencyAlertViewModel] = []
        @Published var bookmarks: [StopViewModel] = []
    }

    fileprivate static var provider = Previews_DebugProvider()

    static var previews: some View {
        MapPanelView(provider: provider)
    }
}

//
//  MapPanelStandardView.swift
//  OBAKit
//
//  Created by Alan Chu on 10/10/22.
//

import SwiftUI
import OBAKitCore
import Introspect

struct MapPanelStandardView: View {
    @ObservedObject public var provider: OBAMapPanelProvider
    public weak var delegate: _MapPanelDelegate?

    @FocusState fileprivate var focusedOnTextField: Bool
    @State fileprivate var selectedItem: MapPanelItemIdentifier?

    var body: some View {
        List(selection: $selectedItem) {
            if provider.alerts.isEmpty == false {
                Section {
                    ForEach(provider.alerts, id: \.id, content: MapPanelAlertView.init)
                } header: {
                    listHeader("Agency Alerts")
                }
            }

            Section {
                ForEach(provider.recentStops, id: \.panelViewIdentifier, content: MapPanelStopView.init)
            } header: {
                listHeader("Recent Stops")
            }

            Section {
                ForEach(provider.nearbyStops, id: \.panelViewIdentifier, content: MapPanelStopView.init)
            } header: {
                listHeader("Nearby Stops")
            }
        }
        .removeListBackground()
        .onAppear {
            self.selectedItem = nil
        }
        .environment(\.editMode, .constant(.active))    // workaround for removing selection background when `selectedItem = nil`.
        .task(id: selectedItem) {
            guard let selectedItem, let delegate else { return }

            switch selectedItem {
            case .stop(let id):
                delegate.didSelect(stop: id)
            case .alert(let id):
                delegate.didSelect(alert: id)
            case .bookmark(let id):
                delegate.didSelect(bookmark: id)
            }
        }
    }

    @ViewBuilder
    fileprivate func listHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(.headline))
    }
}

struct MapPanelView_Previews: PreviewProvider {
    fileprivate static var provider = OBAMapPanelProvider(
        alerts: MapPanelAlertView.Item.samples,
        nearbyStops: StopViewModel.samples,
        recentStops: StopViewModel.samples.reversed())

    static var previews: some View {
        MapPanelStandardView(provider: provider)
    }
}

//
//  OBAMapPanelProvider.swift
//  OBAKit
//
//  Created by Alan Chu on 10/10/22.
//

import Combine
import OBAKitCore

class OBAMapPanelProvider: ObservableObject, MapPanelViewProvider, MapRegionDelegate {
    @Published var alerts: [MapPanelAlertView.Item] = []
    @Published var nearbyStops: [StopViewModel] = []
    @Published var recentStops: [StopViewModel] = []

    func mapRegionManager(_ manager: MapRegionManager, stopsUpdated stops: [Stop]) {
        self.nearbyStops = stops.map { StopViewModel($0) }
    }
}

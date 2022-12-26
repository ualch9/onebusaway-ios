//
//  OBAMapPanelProvider.swift
//  OBAKit
//
//  Created by Alan Chu on 10/10/22.
//

import Combine
import OBAKitCore

class OBAMapPanelProvider: ObservableObject, MapRegionDelegate {
    @Published var alerts: [MapPanelAlertView.Item] = []
    @Published var nearbyStops: [StopViewModel] = []
    @Published var recentStops: [StopViewModel] = []

    init(alerts: [MapPanelAlertView.Item] = [], nearbyStops: [StopViewModel] = [], recentStops: [StopViewModel] = []) {
        self.alerts = alerts
        self.nearbyStops = nearbyStops
        self.recentStops = recentStops
    }

    func mapRegionManager(_ manager: MapRegionManager, stopsUpdated stops: [Stop]) {
        self.nearbyStops = stops.map { StopViewModel($0) }
    }
}

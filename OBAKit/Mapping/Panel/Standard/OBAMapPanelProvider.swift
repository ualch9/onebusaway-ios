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

    typealias SearchResultType = Result<(any QuickSearchResults), Error>
    @Published var searchResults: SearchResultType?

    let searchOptions: [IdentifableQuickSearchOption] = [
        IdentifableQuickSearchOption("route", QuickSearchRoute.self),
        IdentifableQuickSearchOption("address", QuickSearchAddress.self)
    ]

    init(alerts: [MapPanelAlertView.Item] = [],
         nearbyStops: [StopViewModel] = [],
         recentStops: [StopViewModel] = [],
         searchResults: SearchResultType? = nil) {
        self.alerts = alerts
        self.nearbyStops = nearbyStops
        self.recentStops = recentStops
        self.searchResults = nil
    }

    func mapRegionManager(_ manager: MapRegionManager, stopsUpdated stops: [Stop]) {
        self.nearbyStops = stops.map { StopViewModel($0) }
    }
}

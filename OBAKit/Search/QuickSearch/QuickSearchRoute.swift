//
//  QuickSearchRoute.swift
//  OBAKit
//
//  Created by Alan Chu on 12/25/22.
//

import MapKit
import OBAKitCore

struct QuickSearchRouteResults: QuickSearchResults {
    var query: QuickSearch.Query
    var results: [Route]
    var boundingRegion: MKCoordinateRegion?
}

struct QuickSearchRoute: QuickSearchOption {
    static let systemImage: String = "chart.xyaxis.line"
    static let localizedTitle: String = "Route"

    let application: Application

    init(application: Application) {
        self.application = application
    }

    func performSearch(query: String) async throws -> any QuickSearchResults {
        guard let apiService = application.restAPIService,
              let mapRect = application.mapRegionManager.lastVisibleMapRect else {
            throw QuickSearch.Errors.badApplicationState
        }

        return try await withCheckedThrowingContinuation { continuation in
            let operation = apiService.getRoute(query: query, region: CLCircularRegion(mapRect: mapRect))
            operation.complete { result in
                if let error = operation.error {
                    continuation.resume(throwing: error)
                }

                switch result {
                case .failure(let error):
                    continuation.resume(throwing: error)
                case .success(let response):
                    continuation.resume(returning: QuickSearchRouteResults(query: query, results: response.list))
                }
            }
        }
    }
}

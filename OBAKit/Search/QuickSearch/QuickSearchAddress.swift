//
//  QuickSearchAddress.swift
//  OBAKit
//
//  Created by Alan Chu on 12/25/22.
//

import MapKit

struct QuickSearchAddressResults: QuickSearchResults {
    var query: QuickSearch.Query
    var results: [MKMapItem]
    var boundingRegion: MKCoordinateRegion?
}

struct QuickSearchAddress: QuickSearchOption {
    static let systemImage: String = "mappin"
    static let localizedTitle: String = "Address"

    var application: Application
    init(application: Application) {
        self.application = application
    }

    func performSearch(query: String) async throws -> any QuickSearchResults {
        guard let apiService = application.restAPIService,
              let mapRect = application.mapRegionManager.lastVisibleMapRect else {
            throw QuickSearch.Errors.badApplicationState
        }

        return try await withCheckedThrowingContinuation { continuation in
            let operation = apiService.getPlacemarks(query: query, region: MKCoordinateRegion(mapRect))
            operation.completionBlock = {
                if let error = operation.error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(
                        returning: QuickSearchAddressResults(
                            query: query,
                            results: operation.response?.mapItems ?? [],
                            boundingRegion: operation.response?.boundingRegion
                        )
                    )
                }
            }
        }
    }
}

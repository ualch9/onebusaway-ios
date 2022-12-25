//
//  QuickSearchOption.swift
//  OBAKit
//
//  Created by Alan Chu on 12/25/22.
//

import MapKit

enum QuickSearch /* namespace */ {
    typealias Query = String

    enum Errors: Error {
        case badApplicationState
    }
}

protocol QuickSearchResults {
    associatedtype ResultType: Hashable
    var query: QuickSearch.Query { get }
    var results: [ResultType] { get }
    var boundingRegion: MKCoordinateRegion? { get }
}

protocol QuickSearchOption {
    associatedtype ResultsType = QuickSearchResults
    static var systemImage: String { get }
    static var localizedTitle: String { get }

    init(application: Application)
    func performSearch(query: String) async throws -> any QuickSearchResults
}

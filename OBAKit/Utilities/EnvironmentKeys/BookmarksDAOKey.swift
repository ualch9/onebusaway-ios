//
//  BookmarksDAOKey.swift
//  OBAKit
//
//  Created by Alan Chu on 11/3/21.
//

import SwiftUI

struct BookmarksDAOKey: EnvironmentKey {
    static public let defaultValue: BookmarksDataModel = BookmarksDataModel()
}

extension EnvironmentValues {
    var bookmarksDAO: BookmarksDataModel {
        get { self[BookmarksDAOKey.self] }
        set { self[BookmarksDAOKey.self] = newValue }
    }
}

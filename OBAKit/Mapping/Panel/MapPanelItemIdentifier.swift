//
//  MapPanelItemIdentifier.swift
//  OBAKit
//
//  Created by Alan Chu on 12/26/22.
//

import OBAKitCore

/// Shared item identifier for MapPanel stuff
enum MapPanelItemIdentifier: Hashable {
    case stop(Stop.ID)
    case alert(String)
    case bookmark(Bookmark.ID)
}

protocol _MapPanelDelegate: AnyObject {
    @MainActor func didSelect(alert alertID: String)
    @MainActor func didSelect(stop stopID: Stop.ID)
    @MainActor func didSelect(bookmark bookmarkID: Bookmark.ID)
}

//
//  BookmarksViewDelegate.swift
//  OBAKit
//
//  Created by Alan Chu on 11/2/21.
//

import OBAKitCore

public protocol BookmarksViewDelegate: AnyObject {
    func routeToStop(stopID: Stop.ID)
}

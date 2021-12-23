//
//  Layouts.swift
//  OBAKit
//
//  Copyright © Open Transit Software Foundation
//  This source code is licensed under the Apache 2.0 license found in the
//  LICENSE file in the root directory of this source tree.
//

import FloatingPanel
import UIKit

/// A layout object used with `FloatingPanel` on `MapViewController`.
final class MapPanelLayout: NSObject, FloatingPanelLayout {
    var position: FloatingPanelPosition = .bottom
    var initialState: FloatingPanelState
    var anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] {
        return [
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 60, edge: .bottom, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(fractionalInset: 1/2, edge: .bottom, referenceGuide: .safeArea),
            .full: FloatingPanelLayoutAnchor(absoluteInset: 16, edge: .top, referenceGuide: .safeArea)
        ]
    }

    init(initialState: FloatingPanelState) {
        self.initialState = initialState
    }
}

/// A layout object used with `FloatingPanel` on `MapViewController`.
final class MapPanelLandscapeLayout: FloatingPanelLayout {
    static let WidthSize: CGFloat = 291

    var position: FloatingPanelPosition = .bottom
    var initialState: FloatingPanelState

    init(initialState: FloatingPanelState) {
        self.initialState = initialState
    }

    var anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 16, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(fractionalInset: 1/2, edge: .bottom, referenceGuide: .safeArea),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 69, edge: .bottom, referenceGuide: .safeArea)
        ]
    }

    public func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
        return [
            surfaceView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8.0),
            surfaceView.widthAnchor.constraint(equalToConstant: MapPanelLandscapeLayout.WidthSize)
        ]
    }

    public func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        return 0.0
    }
}

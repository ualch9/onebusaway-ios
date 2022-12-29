//
//  RemoveListBackground.swift
//  OBAKit
//
//  Created by Alan Chu on 12/28/22.
//

import SwiftUI
import Introspect

private struct RemoveListBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16, *) {
            content
                .scrollContentBackground(.hidden)
        } else {
            content.introspectTableView { tableView in
                tableView.backgroundColor = .clear
            }
        }
    }
}

extension View {
    func removeListBackground() -> some View {
        self.modifier(RemoveListBackground())
    }
}

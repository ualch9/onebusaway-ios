//
//  KeyValueCell.swift
//  OBAKit
//
//  Created by Alan Chu on 10/6/22.
//

import SwiftUI

struct OptionalText: View {
    @State var value: String?
    @State var nilDisplayValue: String?

    var body: some View {
        if let value {
            Text(value)
                .font(.body)
        } else {
            if let nilDisplayValue {
                Text(nilDisplayValue)
                    .font(.body.monospaced())
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
    }
}

/// Displays a UITableView-like cell, with a key and value. The value is optional, and will display a "Not available" message
struct KeyValueView: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    @State var key: String
    @State var value: String?
    @State var nilDisplayValue: String = "not available"

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading) {
                    Text(key)
                        .font(.headline)

                    OptionalText(value: value, nilDisplayValue: nilDisplayValue)
                }
            } else {
                 HStack {
                     Text(key)
                         .font(.headline)
                     Spacer()
                     OptionalText(value: value, nilDisplayValue: nilDisplayValue)
                }
            }
        }
        .contextMenu {
            if let value {
                Button {
                    UIPasteboard.general.string = value
                } label: {
                    Label("Copy Value", systemImage: "doc.on.doc")
                }
            }
        }
    }
}

struct KeyValueCell_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section("Standard") {
                KeyValueView(key: "Address", value: "asdf")
                KeyValueView(key: "empty data", value: nil)
            }

            Section("Accessibility") {
                KeyValueView(key: "Address", value: "asdf")
                KeyValueView(key: "empty data", value: nil)
            }.environment(\.dynamicTypeSize, .accessibility3)
        }.headerProminence(.increased)
    }
}

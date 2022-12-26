//
//  MapPanelAlertView.swift
//  OBAKit
//
//  Created by Alan Chu on 10/15/22.
//

import SwiftUI
import OBAKitCore

struct MapPanelAlertView: View {
    struct Item: Identifiable, Hashable {
        let id: MapPanelItemIdentifier
        let title: String
        let agencyName: String?

        init(id: String = UUID().uuidString, title: String, agencyName: String?) {
            self.id = .alert(id)
            self.title = title
            self.agencyName = agencyName
        }

        init(_ agencyAlert: AgencyAlert) {
            self.id = .alert(agencyAlert.id)
            self.title = agencyAlert.title(forLocale: .current) ?? ""
            self.agencyName = agencyAlert.affectedAgencyName
        }

        #if DEBUG
        static var samples: [Item] = [
            .init(title: "Please wear a mask.", agencyName: "Metro Transit"),
            .init(title: "Line 1 cancelled", agencyName: "Sound Transit")
        ]
        #endif
    }

    @State var item: Item

    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "exclamationmark.square")

            VStack(alignment: .leading) {
                Text(item.title)
                if let agency = item.agencyName {
                    Text(agency)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
        }
    }
}

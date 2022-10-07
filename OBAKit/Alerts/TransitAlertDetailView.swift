//
//  TransitAlertDetailView.swift
//  OBAKit
//
//  Created by Alan Chu on 10/6/22.
//

import SwiftUI
import OBAKitCore

struct TransitAlertDetailViewModel: Identifiable {
    let id: String
    let agency: String?
    let title: String
    let body: String
    let isBodyAvailable: Bool
    let url: URL?

    let startDate: Date?
    let endDate: Date?

    static func fromAlert(_ alert: TransitAlertViewModel, locale: Locale = .current) -> Self {
        // Account for empty strings
        let alertTitle = alert.title(forLocale: locale) ?? ""
        let title = alertTitle.isEmpty ? Strings.serviceAlert : alertTitle

        let alertBody = alert.body(forLocale: locale) ?? ""
        let isBodyAvailable = !alertBody.isEmpty
        let body = isBodyAvailable ? alertBody : OBALoc("transit_alert.no_additional_details.body", value: "No additional details available.", comment: "A notice when a transit alert doesn't have body text.")

        return self.init(
            id: alert.id,
            agency: alert.affectedAgencyName,
            title: title,
            body: body,
            isBodyAvailable: isBodyAvailable,
            url: alert.url(forLocale: locale),
            startDate: alert.startDate,
            endDate: alert.endDate)
    }
}

struct TransitAlertDetailView: View {
    var viewModel: TransitAlertDetailViewModel

    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var body: some View {
        List {
            Section {
                if let title = viewModel.title {
                    Text(title)
                        .font(.headline)
                }

                Text(viewModel.body)
                    .italic(!viewModel.isBodyAvailable)
                    .foregroundColor(viewModel.isBodyAvailable ? .primary : .secondary)

                if let url = viewModel.url {
                    Link(destination: url) {
                        Label("Visit link", systemImage: "globe")
                    }
                }
            }

            Section {
                KeyValueView(key: "Alert ID", value: viewModel.id)
                KeyValueView(key: "Agency", value: viewModel.agency)
            }

            Section("Effective") {
                KeyValueView(key: "Start", value: viewModel.startDate?.formatted())
                KeyValueView(key: "End", value: viewModel.endDate?.formatted())
            }
        }
        .navigationTitle("Agency Alert")
    }
}

struct AgencyAlertDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TransitAlertDetailView(viewModel: .init(id: "1_123", agency: "Metro Transit", title: "Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur", body: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc bibendum blandit faucibus. Quisque justo libero, convallis et sodales ac, pellentesque in orci. Nullam id volutpat tellus. Proin sed risus et risus tincidunt cursus. Nunc tempus tellus auctor arcu eleifend ultrices. Proin auctor tellus eros, sed suscipit sem porta et. In condimentum dui ut dolor tincidunt, sit amet sagittis dolor vehicula. Aenean ullamcorper, enim eget cursus pulvinar, dolor dui dapibus risus, et scelerisque massa enim eget augue. Phasellus justo nulla, pretium sed molestie a, lobortis vel dui. Phasellus at nibh urna. In eu lacinia turpis. Ut nisl metus, volutpat a elit ac, tincidunt volutpat sapien. Curabitur luctus a libero in pulvinar. Curabitur sed sagittis ipsum, vitae pulvinar libero.", isBodyAvailable: true, url: URL(string: "https://www.example.com"), startDate: Date(), endDate: .distantFuture))
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

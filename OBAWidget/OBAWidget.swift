//
//  Widget.swift
//  Widget
//
//  Created by Alan Chu on 5/15/21.
//

import WidgetKit
import SwiftUI
import Intents
import MapKit
import OBAKitCore

struct NextArrivalDepartureProvider: IntentTimelineProvider {
    typealias Entry = NextArrivalDepartureEntry
    typealias Intent = ConfigurationIntent

    func placeholder(in context: Context) -> Entry {
        return .init(generatedAt: Date(),
                     bookmarkName: "Bookmark",
                     routeName: "",
                     departureTimeViewModel:
                        .init(arrivalDepartureDate: Date(), temporalState: .present, scheduleStatus: .unknown),
                     configuration: ConfigurationIntent())
    }

    func mapType(for configuration: Intent) -> MKMapType? {
        switch configuration.mapStyle {
        case .unknown, .none:
            return nil
        case .standard:
            return .standard
        case .satellite:
            return .satellite
        }
    }

    func getSnapshot(for configuration: Intent, in context: Context, completion: @escaping (Entry) -> Void) {
        completion(.example())
    }

    func getTimeline(for configuration: Intent, in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        completion(Timeline<Entry>(entries: [.example()], policy: .atEnd))
    }
}

struct NextArrivalDepartureEntry: TimelineEntry {
    /// `TimelineEntry` date.
    let date: Date
    let configuration: ConfigurationIntent

    /// When was this entry generated?
    let generatedAt: Date
    let bookmarkName: String
    let routeName: String

    let departureTimeViewModel: DepartureTimeViewModel

    init(generatedAt: Date,
         bookmarkName: String,
         routeName: String,
         departureTimeViewModel: DepartureTimeViewModel,
         configuration: ConfigurationIntent) {
        self.generatedAt = generatedAt
        self.bookmarkName = bookmarkName
        self.routeName = routeName

        self.date = Date()
        self.departureTimeViewModel = departureTimeViewModel
        self.configuration = configuration
    }

    static func example() -> Self {
        let gen = Date().addingTimeInterval(-10)
        return .init(generatedAt: gen, bookmarkName: "10 to Home", routeName: "B Line", departureTimeViewModel: .init(arrivalDepartureDate: Date(), temporalState: .present, scheduleStatus: .onTime), configuration: ConfigurationIntent())
    }
}

struct OBAWidgetEntryView : View {
    static let timeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .short
        return formatter
    }()

    var entry: NextArrivalDepartureProvider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(entry.bookmarkName)
                        .lineLimit(nil)
                        .font(.caption)
                }

                VStack {
                    DepartureTimeView(viewModel: entry.departureTimeViewModel)
                        .fixedSize()
                    DepartureTimeView(viewModel: entry.departureTimeViewModel)
                        .fixedSize()
                }
            }

            Spacer()
            
            Text("Last updated:").font(.caption2)
            Text(entry.date, formatter: Self.timeFormatter).font(.caption2)
        }

        .padding()
    }
}

@main
struct OBAWidget: Widget {
    let kind: String = "Widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: NextArrivalDepartureProvider()) { entry in
            OBAWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct OBAWidget_Previews: PreviewProvider {
    static var previews: some View {
        OBAWidgetEntryView(entry: .example())
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

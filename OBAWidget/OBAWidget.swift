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

//struct Provider: IntentTimelineProvider {
//    func placeholder(in context: Context) -> SimpleEntry {
//        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
//    }
//
//    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
//        let entry = SimpleEntry(date: Date(), configuration: configuration)
//        completion(entry)
//    }
//
//    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
//        var entries: [SimpleEntry] = []
//
//        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        let currentDate = Date()
//        for hourOffset in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            let entry = SimpleEntry(date: entryDate, configuration: configuration)
//            entries.append(entry)
//        }
//
//        let timeline = Timeline(entries: entries, policy: .atEnd)
//        completion(timeline)
//    }
//}
//
//struct SimpleEntry: TimelineEntry {
//    let date: Date
//    let configuration: ConfigurationIntent
//}

struct NextArrivalDepartureProvider: IntentTimelineProvider {
    typealias Entry = NextArrivalDepartureEntry
    typealias Intent = ConfigurationIntent

    func placeholder(in context: Context) -> Entry {
        return .init(date: Date(), configuration: ConfigurationIntent(), stopID: "", stopName: "Placeholder", routeName: "000",  nextArrDepDate: Date(), backgroundImage: nil)
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
        if let mapType = mapType(for: configuration) {
            let coordinates = CLLocationCoordinate2D(latitude: 47.622570, longitude: -122.312542)
            let options: MKMapSnapshotter.Options = .init()
            options.mapType = mapType
            options.pointOfInterestFilter = MKPointOfInterestFilter(including: [])
            options.region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 100, longitudinalMeters: 100)

            let snapshotter = MKMapSnapshotter(options: options)
            snapshotter.start { snapshot, error in
                completion(.example(snapshot?.image))
            }
        } else {
            completion(.example())
        }
    }

    func getTimeline(for configuration: Intent, in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        if let mapType = mapType(for: configuration) {
            let coordinates = CLLocationCoordinate2D(latitude: 47.622570, longitude: -122.312542)
            let options: MKMapSnapshotter.Options = .init()
            options.mapType = mapType
            options.pointOfInterestFilter = MKPointOfInterestFilter(including: [])
            options.region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 100, longitudinalMeters: 100)

            let snapshotter = MKMapSnapshotter(options: options)
            snapshotter.start { snapshot, error in
                completion(Timeline<Entry>(entries: [.example(snapshot?.image)], policy: .atEnd))
            }
        } else {
            completion(Timeline<Entry>(entries: [.example()], policy: .atEnd))
        }
    }
}

struct NextArrivalDepartureEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent

    let stopID: String
    let stopName: String
    let routeName: String

    let nextArrDepDate: Date
    let backgroundImage: UIImage?
//    let arrivalDeparture: ArrivalDeparture.

    static func example(_ bgImage: UIImage? = nil) -> Self {
        return .init(date: Date(), configuration: ConfigurationIntent(), stopID: "1_1234", stopName: "Broadway E & IDK", routeName: "B Line", nextArrDepDate: Date().addingTimeInterval(60 * 15), backgroundImage: bgImage)
    }
}

struct OBAWidgetEntryView : View {
    static let timeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        return formatter
    }()

    var entry: NextArrivalDepartureProvider.Entry

    var body: some View {
        if let bgImage = entry.backgroundImage {
            ZStack {
                Image(uiImage: bgImage)
                    .edgesIgnoringSafeArea(.all)
                    .blur(radius: 2, opaque: true)

                VStack(alignment: .leading) {
                    Text(entry.routeName)
                    Text(entry.nextArrDepDate, formatter: Self.timeFormatter)
                }
            }
        } else {
            VStack(alignment: .leading) {
                Text("NO BG")
                Text(entry.routeName)
                Text(entry.nextArrDepDate, formatter: Self.timeFormatter)
            }
        }
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

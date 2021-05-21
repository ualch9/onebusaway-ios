//
//  ScheduleStatusViewModifier.swift
//  OBAKitCore
//
//  Created by Alan Chu on 5/20/21.
//

import SwiftUI

struct ScheduleStatusViewModifier: ViewModifier {
    var scheduleStatus: ScheduleStatus

    var scheduleStatusColor: Color {
        switch scheduleStatus {
        case .delayed:
            return Color(ThemeColors.shared.departureLateBackground)
        case .early:
            return Color(ThemeColors.shared.departureEarlyBackground)
        case .onTime:
            return Color(ThemeColors.shared.departureOnTimeBackground)
        case .unknown:
            return Color(ThemeColors.shared.departureUnknownBackground)
        }
    }

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // ↑ For resizable background frame. See preview "multiple labels of same size".
            .background(scheduleStatusColor)
    }
}

extension View {
    /// Applies the specified schedule status as the background color.
    ///
    /// - parameter scheduleStatus: The schedule status to apply to this view.
    ///
    /// ## Example Usage
    /// ```swift
    /// Text("5m")
    ///   .scheduleStatus(.onTime)
    /// ```
    public func scheduleStatus(_ scheduleStatus: ScheduleStatus) -> some View {
        self.modifier(ScheduleStatusViewModifier(scheduleStatus: scheduleStatus))
    }
}

struct ScheduleStatusViewModifierPreviews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .center, spacing: 16) {
            Text("3m")
                .scheduleStatus(.onTime)
            Text("13m")
                .scheduleStatus(.early)
            Text("12345m")
                .scheduleStatus(.delayed)
        }
        .fixedSize()
        .padding()
        .previewDisplayName("Multiple labels of same size")
        .previewLayout(.sizeThatFits)
    }
}

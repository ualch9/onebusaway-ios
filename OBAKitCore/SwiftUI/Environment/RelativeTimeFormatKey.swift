//
//  RelativeTimeFormatKey.swift
//  OBAKitCore
//
//  Created by Alan Chu on 5/24/21.
//

import SwiftUI

public enum RelativeTimeFormat {
    /// # In US English
    ///
    /// Time Format: `hh:mm`.
    ///
    /// ## Examples (US English)
    /// - `"1:35"` is 1 hour and 35 minutes / 95 minutes.
    /// - `"0:20"` is 0 hours and 20 minutes / 20 minutes.
    /// - `"-0:05"` is 5 minutes ago.
    case hoursAndMinutes

    /// # In US English
    /// Time Format: `m + 'm'`.
    ///
    /// ## Examples (US English)
    /// - `"95m"` is 95 minutes / 1 hour and 35 minutes.
    /// - `"5m"` is 5 minutes / 0 hours and 5 minutes.
    /// - `"-7m"` is 7 minutes ago.
    case minutesOnly

    /// # In US English
    /// This format suppresses zero hours, e.g. 0 hours and 20 minutes will result in `"20m"`.
    ///
    /// ## Examples (US English)
    /// - 5 minutes results in `"5m"`
    /// - 20 minutes results in `"20m"`
    /// - 60 minutes results in `"1:00"`
    /// - 74 minutes results in `"1:14"`
    /// - 5,125 minutes results in `"85:25"`
    /// - 5 minutes ago results in `"-5m"`
    /// - 82 minutes ago results in `"-1:22"`
    case mixed
}

/// Used by `DepartureTimeView`.
private struct RelativeTimeFormatKey: EnvironmentKey {
    static let defaultValue: RelativeTimeFormat = .minutesOnly
}

extension EnvironmentValues {
    var relativeTimeFormat: RelativeTimeFormat {
        get { self[RelativeTimeFormatKey.self] }
        set { self[RelativeTimeFormatKey.self] = newValue }
    }
}

extension View {
    func relativeTimeFormat(_ format: RelativeTimeFormat) -> some View {
        environment(\.relativeTimeFormat, format)
    }
}

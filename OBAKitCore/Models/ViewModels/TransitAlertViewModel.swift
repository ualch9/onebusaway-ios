//
//  TransitAlertViewModel.swift
//  OBAKitCore
//
//  Created by Alan Chu on 1/18/21.
//

/// Wraps `AgencyAlert` and `ServiceAlert` into a common view model for displaying alert details in-app.
public protocol TransitAlertViewModel {
    var id: String { get }

    var affectedAgencyName: String? { get }

    var startDate: Date? { get }
    var endDate: Date? { get }

    /// The closest matching localized title text for the specified `Locale`.
    func title(forLocale locale: Locale) -> String?

    /// The closest matching localized body text describing the alert in full detail for the specified `Locale`.
    func body(forLocale locale: Locale) -> String?

    /// The closest matching localized URL for the specified `Locale`.
    func url(forLocale locale: Locale) -> URL?
}

extension AgencyAlert: TransitAlertViewModel {
    public var affectedAgencyName: String? {
        return self.agency?.agency.name
    }
}

extension ServiceAlert: TransitAlertViewModel {
    public var affectedAgencyName: String? {
        return affectedAgencies.map { $0.name }.sorted().joined(separator: ", ")
    }

    fileprivate var closestActiveWindow: TimeWindow? {
        return self.activeWindows.allObjects.sorted(by: \.from).first
    }

    public var startDate: Date? {
        return closestActiveWindow?.from
    }

    public var endDate: Date? {
        return closestActiveWindow?.to
    }

    public func title(forLocale locale: Locale) -> String? {
        return summary?.value
    }

    public func body(forLocale locale: Locale) -> String? {
        return affectedAgencyName
    }

    public func url(forLocale locale: Locale) -> URL? {
        guard let urlString = self.urlString else { return nil }
        return URL(string: urlString.value)
    }
}

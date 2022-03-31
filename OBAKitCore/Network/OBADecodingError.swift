//
//  OBADecodingError.swift
//  OBAKitCore
//
//  Created by Alan Chu on 3/4/22.
//

import Foundation

/// A parsed `DecodingError` providing the specific missing/corrupted key. Use as a standard `NSError`.
///
/// Available properties:
/// - `localizedDescription`
/// - `localizedFailureReason`
/// - `userInfo[NSURLErrorKey]?` (optional)
public struct OBADecodingError: CustomNSError {
    public static let errorDomain = "OBADecodingError"

    public let errorCode = 500
    public let errorUserInfo: [String: Any]

    fileprivate static var defaultLocalizedUserFacingString: String {
        OBALoc("OBADecodingError.defaultUserFacingDescription",
               value: "The server for this transit region is having issues.",
               comment: "Describe to the user that their transit region's server is having temporary issues.")
    }

    /// - parameter error: Is of type `DecodingError`.
    public init?(_ error: Error, url: URL? = nil) {
        guard let decodingError = error as? DecodingError else {
            return nil
        }

        switch decodingError {
        case .typeMismatch:
            self.errorUserInfo = OBADecodingError.userInfo(developerFacingDescription: OBADecodingError.parseTypeMismatch(decodingError), url: url)
        case .valueNotFound:
            self.errorUserInfo = OBADecodingError.userInfo(developerFacingDescription: OBADecodingError.parseValueNotFound(decodingError), url: url)
        case .keyNotFound:
            self.errorUserInfo = OBADecodingError.userInfo(developerFacingDescription: OBADecodingError.parseKeyNotFound(decodingError), url: url)
        case .dataCorrupted:
            return nil
        @unknown default:
            return nil
        }
    }

    fileprivate static func userInfo(
        userFacingDescription: String = defaultLocalizedUserFacingString,
        developerFacingDescription: String,
        url: URL? = nil
    ) -> [String: Any] {
        if let url = url {
            return [
                NSLocalizedDescriptionKey: userFacingDescription,
                NSLocalizedFailureReasonErrorKey: developerFacingDescription,
                NSURLErrorKey: url
            ]
        } else {
            return [
                NSLocalizedDescriptionKey: userFacingDescription,
                NSLocalizedFailureReasonErrorKey: developerFacingDescription
            ]
        }
    }

    fileprivate static func parseCodingPath(_ codingPath: [CodingKey]) -> String {
        return "`\(codingPath.map { $0.stringValue }.joined(separator: "."))`"
    }

    fileprivate static func parseKeyNotFound(_ decodingError: DecodingError) -> String {
        guard case let DecodingError.keyNotFound(codingKey, context) = decodingError else {
            return decodingError.localizedDescription
        }

        var fullCodingPath = context.codingPath
        fullCodingPath.append(codingKey)

        return "Missing required key \(parseCodingPath(fullCodingPath))."
    }

    fileprivate static func parseValueNotFound(_ decodingError: DecodingError) -> String {
        guard case let DecodingError.valueNotFound(expectedType, context) = decodingError else {
            return decodingError.localizedDescription
        }

        return "Missing required `\(String(describing: expectedType))` value for key \(parseCodingPath(context.codingPath)) (key exists, but either empty or NULL value)."
    }

    fileprivate static func parseTypeMismatch(_ decodingError: DecodingError) -> String {
        guard case let DecodingError.typeMismatch(expectedType, context) = decodingError else {
            return decodingError.localizedDescription
        }

        return "Expected a \(String(describing: expectedType)) at \(parseCodingPath(context.codingPath))."
    }
}

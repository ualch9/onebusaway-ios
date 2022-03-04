//
//  DecodingErrorLocalizedParser.swift
//  OBAKitCore
//
//  Created by Alan Chu on 3/4/22.
//

import Foundation

public class DecodingErrorLocalizedParser {
    public static func parse(_ decodingError: DecodingError) -> String {
        switch decodingError {
        case .typeMismatch:
            return parseTypeMismatch(decodingError)
        case .valueNotFound:
            return decodingError.localizedDescription
        case .keyNotFound:
            return parseKeyNotFound(decodingError)
        case .dataCorrupted:
            return decodingError.localizedDescription
        @unknown default:
            return decodingError.localizedDescription
        }
    }

    fileprivate static func parseCodingPath(_ codingPath: [CodingKey]) -> String {
        return "`\(codingPath.map { $0.stringValue }.joined(separator: "."))`"
    }

    fileprivate static func parseKeyNotFound(_ decodingError: DecodingError) -> String {
        guard case let DecodingError.keyNotFound(codingKey, context) = decodingError else { return "" }

        var fullCodingPath = context.codingPath
        fullCodingPath.append(codingKey)

        return "Missing data: \(parseCodingPath(fullCodingPath))."
    }

    fileprivate static func parseTypeMismatch(_ decodingError: DecodingError) -> String {
        guard case let DecodingError.typeMismatch(expectedType, context) = decodingError else { return "" }
        return "Expected a \(String(describing: expectedType)) at \(parseCodingPath(context.codingPath))."
    }
}

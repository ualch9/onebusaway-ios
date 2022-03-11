//
//  DecodingErrorLocalizedParserTests.swift
//  OBAKitTests
//
//  Created by Alan Chu on 3/4/22.
//

import XCTest
import OBAKitCore

/// This test case ensures that the relevant decoding error information is included in the displayable description.
/// Primarily, indicating which specific JSON key has issues, which is causing decoding to fail. See `DecodingErrorLocalizedParser` for more details.
class DecodingErrorLocalizedParserTests: XCTestCase {
    // MARK: - Test models
    fileprivate struct Vehicle: Codable {
        let year: Int
        let make: String
        let model: String

        let owner: Owner
    }

    fileprivate struct Owner: Codable {
        fileprivate struct ContactInfo: Codable {
            let phoneNumber: String
            let email: String
        }

        let name: String
        let address: String
        let contactInfo: ContactInfo
    }

    fileprivate static let requestURL: URL = URL(string: "https://example.com/registered_owner?vin=ABCDEFG&id=1A2B3C")!

    // MARK: - Unit Testing
    let decoder = JSONDecoder()

    func testMissingValue() {
        let missingOwnerContactEmail = """
        {
            "year": 2018,
            "make": "Honda",
            "model": "Accord",
            "owner": {
                "name": "Alan Chu",
                "address": "Bellevue, WA",
                "contactInfo": {
                    "phoneNumber": "4255555555"
                }
            }
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(Vehicle.self, from: missingOwnerContactEmail), "") { error in
            let obaError: NSError = OBADecodingError(error as! DecodingError, url: Self.requestURL)! as NSError
            XCTAssertFalse(obaError.localizedDescription.isEmpty, "Localized description should not be empty.")
            XCTAssertTrue(obaError.localizedFailureReason!.contains("owner.contactInfo.email"), "MissingKey localized should contain the path \"owner.contactInfo.email\" somewhere in the string.")
            XCTAssertEqual(obaError.userInfo[NSURLErrorKey] as! URL, Self.requestURL)
        }
    }

    func testTypeMismatchValue() {
        let typeMismatchOwnerContactPhone = """
        {
            "year": 2018,
            "make": "Honda",
            "model": "Accord",
            "owner": {
                "name": "Alan Chu",
                "address": "Bellevue, WA",
                "contactInfo": {
                    "phoneNumber": 4255555555,
                    "email": "alan@example.com"
                }
            }
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(Vehicle.self, from: typeMismatchOwnerContactPhone), "") { error in
            let obaError: NSError = OBADecodingError(error as! DecodingError, url: Self.requestURL)! as NSError
            XCTAssertFalse(obaError.localizedDescription.isEmpty, "Localized description should not be empty.")
            XCTAssertTrue(obaError.localizedFailureReason!.contains("owner.contactInfo.phoneNumber"), "TypeMismatch localized should contain the path \"owner.contactInfo.phoneNumber\" somewhere in the string.")
            XCTAssertEqual(obaError.userInfo[NSURLErrorKey] as! URL, Self.requestURL)
        }
    }

    func testUnexpectedNullValueOrValueNotFound() {
        let nullValue = """
        {
            "year": 2018,
            "make": "Honda",
            "model": "Accord",
            "owner": {
                "name": "Alan Chu",
                "address": "Bellevue, WA",
                "contactInfo": {
                    "phoneNumber": null,
                    "email": "alan@example.com"
                }
            }
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(Vehicle.self, from: nullValue), "") { error in
            let obaError: NSError = OBADecodingError(error as! DecodingError, url: Self.requestURL)! as NSError
            XCTAssertFalse(obaError.localizedDescription.isEmpty, "Localized description should not be empty.")
            XCTAssertTrue(obaError.localizedFailureReason!.contains("owner.contactInfo.phoneNumber"), "TypeMismatch localized should contain the path \"owner.contactInfo.phoneNumber\" somewhere in the string.")
            XCTAssertTrue(obaError.localizedFailureReason!.lowercased().contains("string"), "TypeMismatch localized should contain the expected type, \"String\", somewhere in the string.")
            XCTAssertEqual(obaError.userInfo[NSURLErrorKey] as! URL, Self.requestURL)
        }
    }
}

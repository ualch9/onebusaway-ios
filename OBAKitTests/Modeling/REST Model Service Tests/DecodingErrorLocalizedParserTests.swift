//
//  DecodingErrorLocalizedParserTests.swift
//  OBAKitTests
//
//  Created by Alan Chu on 3/4/22.
//

import XCTest
import OBAKitCore

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

    // MARK: - Test inputs
    fileprivate let missingOwnerContactEmail = """
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

    fileprivate let typeMismatchOwnerContactPhone = """
    {
        "year": 2018,
        "make": "Honda",
        "model": "Accord",
        "owner": {
            "name": "Alan Chu",
            "address": "Bellevue, WA",
            "contactInfo": {
                "phoneNumber": 4255555555,
                "email: "alan@example.com"
            }
        }
    }
    """.data(using: .utf8)!

    fileprivate let nullValue = """
    {
        "year": 2018,
        "make": "Honda",
        "model": "Accord",
        "owner": {
            "name": "Alan Chu",
            "address": "Bellevue, WA",
            "contactInfo": {
                "phoneNumber": null,
                "email: "alan@example.com"
            }
        }
    }
    """.data(using: .utf8)!

    // MARK: - Unit Testing
    let decoder = JSONDecoder()

    func testMissingValue() {
        XCTAssertThrowsError(try decoder.decode(Vehicle.self, from: missingOwnerContactEmail), "") { error in
            let localized = DecodingErrorLocalizedParser.parse(error as! DecodingError)
            XCTAssertTrue(localized.contains("owner.contactInfo.email"), "MissingKey localized should contain the path \"owner.contactInfo.email\" somewhere in the string.")
        }
    }
}

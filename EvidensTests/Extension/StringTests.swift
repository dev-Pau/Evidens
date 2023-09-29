//
//  StringTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 29/9/23.
//

import XCTest
@testable import Evidens

final class StringTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testString_WhenStringContaintsOnlyEmoji_ShouldReturnTrue() {
        XCTAssertTrue("😀😂👍".containsEmojiOnly)
    }
    
    func testString_WhenStringNotContainsEmoji_ShouldReturnFalse() {
        XCTAssertFalse("Hello, World!".containsEmojiOnly)
    }
    
    func testString_WhenEmailIsValid_ShouldReturnTrue() {
        XCTAssertTrue("test@example.com".emailIsValid)
    }
    
    func testString_WhenEmailIsInvalid_ShouldReturnFalse() {
        XCTAssertFalse("notanemail".emailIsValid)
    }
    
    func testLocalized_WhenKeyExists_ReturnsLocalizedString() {
        let key = "health.discipline.medicine"
        let expectedLocalizedString = "Medicine"
        
        let result = expectedLocalizedString.localized(key: key)
        
        XCTAssertTrue(["Medicine", "Medicina", "Medicina"].contains(result))
    }
}

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
    
    func testWhenContaintsOnlyEmoji() {
        XCTAssertTrue("😀😂👍".containsEmojiOnly)
    }
    
    func testWhenNotContainsEmoji() {
        XCTAssertFalse("Hello, World!".containsEmojiOnly)
    }
    
    func testWhenEmailIsValid() {
        XCTAssertTrue("test@example.com".emailIsValid)
    }
    
    func testWhenEmailIsInvalid() {
        XCTAssertFalse("notanemail".emailIsValid)
    }
    
    func testLocalizedWhenKeyExists() {
        let key = "health.discipline.medicine"
        let expectedLocalizedString = "Medicine"
        
        let result = expectedLocalizedString.localized(key: key)
        
        XCTAssertTrue(["Medicine", "Medicina", "Medicina"].contains(result))
    }
}

//
//  DateTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 28/9/23.
//

import XCTest
@testable import Evidens

final class DateTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testDate_WhenFormattingToUTCTimestamp() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let date = dateFormatter.date(from: "2023-09-28 12:00:00")!
        
        XCTAssertEqual(date.toUTCTimestamp(), 1695902400)
    }
    
    func testDate_WhenFormattingToUTCDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let date = dateFormatter.date(from: "2023-09-28 12:00:00")!
        
        let utcDate = date.toUTCDate()
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
        
        XCTAssertEqual(calendar.component(.year, from: utcDate), 2023)
        XCTAssertEqual(calendar.component(.month, from: utcDate), 9)
        XCTAssertEqual(calendar.component(.day, from: utcDate), 28)
        XCTAssertEqual(calendar.component(.hour, from: utcDate), 12)
        XCTAssertEqual(calendar.component(.minute, from: utcDate), 0)
        XCTAssertEqual(calendar.component(.second, from: utcDate), 0)
    }
}

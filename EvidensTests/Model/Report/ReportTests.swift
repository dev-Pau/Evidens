//
//  ReportTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 12/12/23.
//

import XCTest
@testable import Evidens

final class ReportTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInitializerWithDictionary() {
        let dictionary: [String: Any] = [
            "contentId": "123",
            "userId": "456",
            "uid": "789",
            "source": ReportSource.comment.rawValue,
            "target": ReportTarget.myself.rawValue,
            "topic": ReportTopic.identity.rawValue,
            "content": "Example report content"
        ]
        
        let report = Report(dictionary: dictionary)
        
        XCTAssertEqual(report.contentId, "123")
        XCTAssertEqual(report.userId, "456")
        XCTAssertEqual(report.uid, "789")
        XCTAssertEqual(report.source, ReportSource.comment)
        XCTAssertEqual(report.target, ReportTarget.myself)
        XCTAssertEqual(report.topic, ReportTopic.identity)
        XCTAssertEqual(report.content, "Example report content")
    }
    
    func testInitializerWithRequiredProperties() {
        let report = Report(contentId: "123", userId: "456", uid: "789", source: .post)
        
        XCTAssertEqual(report.contentId, "123")
        XCTAssertEqual(report.userId, "456")
        XCTAssertEqual(report.uid, "789")
        XCTAssertEqual(report.source, .post)
        XCTAssertNil(report.target)
        XCTAssertNil(report.topic)
        XCTAssertNil(report.content)
    }
}

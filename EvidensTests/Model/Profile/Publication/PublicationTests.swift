//
//  PublicationTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
import Firebase
@testable import Evidens

final class PublicationTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInitializerWithDictionary() {
        let timeInterval = TimeInterval()
        let dictionary: [String: Any] = [
            "id": "publication123",
            "title": "Sample Publication",
            "url": "https://example.com/publication",
            "timestamp": timeInterval,
            "uids": ["user123", "user456"]
        ]
        
        let publication = Publication(dictionary: dictionary)
        
        XCTAssertEqual(publication.id, "publication123")
        XCTAssertEqual(publication.title, "Sample Publication")
        XCTAssertEqual(publication.url, "https://example.com/publication")
        XCTAssertEqual(publication.timestamp, timeInterval)
        XCTAssertEqual(publication.uids, ["user123", "user456"])
        XCTAssertEqual(publication.users, [])
    }
    
    func testInitializerWithRequiredProperties() {
        let timeInterval = TimeInterval()
        
        let publication = Publication(id: "publication456", title: "Another Publication", url: "https://example.com/another", timestamp: timeInterval, uids: ["user789"])
        
        XCTAssertEqual(publication.id, "publication456")
        XCTAssertEqual(publication.title, "Another Publication")
        XCTAssertEqual(publication.url, "https://example.com/another")
        XCTAssertEqual(publication.timestamp, timeInterval)
        XCTAssertEqual(publication.uids, ["user789"])
        XCTAssertEqual(publication.users, [])
    }
}

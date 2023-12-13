//
//  CaseRevisionTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
import Firebase
@testable import Evidens

final class CaseRevisionTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInitWithDictionary() {
        let timestamp = Timestamp(date: Date())
                                  
        let dictionary: [String: Any] = [
            "title": "Revision Title",
            "content": "Revision Content",
            "kind": 1,
            "timestamp": timestamp
        ]
        
        let revision = CaseRevision(dictionary: dictionary)
        
        XCTAssertEqual(revision.title, "Revision Title")
        XCTAssertEqual(revision.content, "Revision Content")
        XCTAssertEqual(revision.kind, .update)
        XCTAssertNotNil(revision.timestamp)
    }
    
    func testInitWithDefaultValues() {
        let revision = CaseRevision(content: "Default Content", kind: .clear)
        
        XCTAssertNil(revision.title)
        XCTAssertEqual(revision.content, "Default Content")
        XCTAssertEqual(revision.kind, .clear)
        XCTAssertNotNil(revision.timestamp)
    }
}

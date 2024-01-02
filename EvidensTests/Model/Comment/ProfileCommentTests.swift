//
//  ProfileCommentTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
import Firebase
@testable import Evidens

final class ProfileCommentTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testProfileCommentInitialization() {
        let commentDictionary: [String: Any] = [
            "id": "comment123",
            "kind": 1,
            "source": 0,
            "contentId": "post456",
            "timestamp": TimeInterval(1234567890),
            "path": ["root", "subpath", "subsubpath"]
        ]

        let profileComment = ProfileComment(dictionary: commentDictionary)
        
        XCTAssertEqual(profileComment.id, "comment123")
        XCTAssertEqual(profileComment.kind, .reply)
        XCTAssertEqual(profileComment.source, .post)
        XCTAssertEqual(profileComment.contentId, "post456")
        XCTAssertEqual(profileComment.timestamp, TimeInterval(1234567890))
        XCTAssertEqual(profileComment.path, ["root", "subpath", "subsubpath"])
        XCTAssertEqual(profileComment.content, "")
    }
    
    func testSetComment() {
        var profileComment = ProfileComment(dictionary: [:])

        XCTAssertEqual(profileComment.content, "")

        profileComment.setComment("This is a test comment")
        XCTAssertEqual(profileComment.content, "This is a test comment")
    }
}

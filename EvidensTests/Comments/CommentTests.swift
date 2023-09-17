//
//  CommentTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 15/9/23.
//

import XCTest
@testable import Evidens
import Firebase

final class CommentTests: XCTestCase {
    
    var sut: Comment!
    var timestamp: Timestamp!
    
    override func setUpWithError() throws {

        timestamp = Timestamp(date: Date())
        
        let comment: [String: Any] = [
            "uid": "userId",
            "id": "commentId",
            "timestamp": timestamp as Any,
            "comment": "This is a comment",
            "visible": 1
        ]
        
        sut = Comment(dictionary: comment)
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testComment_WhenCommentIsInitialized_ValuesShouldBeInitialized() {
        XCTAssertEqual(sut.uid, "userId")
        XCTAssertEqual(sut.id, "commentId")
        XCTAssertEqual(sut.timestamp, timestamp)
        XCTAssertEqual(sut.comment, "This is a comment")
        XCTAssertEqual(sut.visible.rawValue, 1)
    }
    
    func testcomment_WhenIsAuthorIsTrue_ShouldReturnTrue() {
        XCTAssertFalse(sut.isAuthor)
        
        sut.edit(true)
        
        XCTAssertTrue(sut.isAuthor)
    }
}

//
//  CommentViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 15/9/23.
//

import XCTest
@testable import Evidens
import Firebase

final class CommentViewModelTests: XCTestCase {
    
    var sut: CommentViewModel!

    override func setUpWithError() throws {
        
        let data: [String: Any] = [
            "uid": "userId",
            "id": "commentId",
            "timestamp": Timestamp(date: Date()),
            "comment": "This is a comment",
            "visible": 1
        ]
        
        let comment = Comment(dictionary: data)
        sut = CommentViewModel(comment: comment)
    }

    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testCommentViewModel_WhenIsInitialized_ValuesShouldBeInitialized() {
        XCTAssertEqual(sut.uid, "userId")
        XCTAssertEqual(sut.anonymous, true)
        XCTAssertEqual(sut.isAuthor, false)
        XCTAssertEqual(sut.content, "This is a comment")
        XCTAssertEqual(sut.visible.rawValue, 1)
    }
    
    func testCommentViewModel_WhenCommentHasCommentsFromAuthor_ShouldReturnTrue() {
        sut.comment.numberOfComments = 2
        sut.comment.hasCommentFromAuthor = true
        
        XCTAssertTrue(sut.hasCommentFromAuthor)
    }
    
    func testCommentViewModel_WhenCommentHasNoCommentsFromAuthor_ShouldReturnFalse() {
        sut.comment.numberOfComments = 2
        sut.comment.hasCommentFromAuthor = false
        
        XCTAssertFalse(sut.hasCommentFromAuthor)
    }
    
    func testCommentViewModel_WhenCommentHasNoComments_ShouldReturnFalse() {
        sut.comment.numberOfComments = 0

        XCTAssertFalse(sut.hasCommentFromAuthor)
    }
    
    func testCommentViewModel_WhenCommentHasComments_ShouldReturnNumberOfComments() {
        sut.comment.numberOfComments = 2
        XCTAssertEqual(sut.numberOfComments, 2)
    }
    
    func testCommentViewModel_WhenCommentHasComments_ShouldReturnNumberOfCommentsAsString() {
        sut.comment.numberOfComments = 2
        XCTAssertEqual(sut.numberOfCommentsText, "2")
    }
    
    func testCommentViewModel_WhenCommentHasNoComments_ShouldReturnEmptyString() {
        sut.comment.numberOfComments = 0
        XCTAssertEqual(sut.numberOfCommentsText, "")
    }
    
    func testCommentViewModel_WhenCommentHasLikes_ShouldReturnNumberOfLikes() {
        sut.comment.likes = 3
        XCTAssertEqual(sut.likes, 3)
    }
    
    func testCommentViewModel_WhenCommentHasLikes_ShouldReturnNumberOfLikesAsString() {
        sut.comment.likes = 2
        XCTAssertEqual(sut.likesText, "2")
    }
    
    func testCommentViewModel_WhenCommentHasNoLikes_ShouldReturnEmptyString() {
        sut.comment.likes = 0
        XCTAssertEqual(sut.likesText, "")
    }
    
    
}

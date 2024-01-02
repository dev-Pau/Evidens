//
//  PostViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 2/1/24.
//

import XCTest
import Firebase
@testable import Evidens

final class PostViewModelTests: XCTestCase {

    var sut: PostViewModel!
    
    override func setUpWithError() throws {
        
        let postData: [String: Any] = [
            "post": "This is the post text",
            "uid": "testUID",
            "timestamp": Timestamp(date: Date()),
            "kind": 1,
            "disciplines": [2, 3],
            "privacy": 1,
            "visible": 2,
            "imageUrl": ["https://image_url1.com", "https://image_url2.com"],
            "reference": 1,
            "edited": true,
            "hashtags": ["#test1", "#test2"]
        ]
        
        let post = Post(postId: "testPostId", dictionary: postData)
        
        sut = PostViewModel(post: post)
    }

    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testText() {
        XCTAssertEqual(sut.postText, "This is the post text")
    }
    
    func testNumberOfComments() {
        sut.post.numberOfComments = 2
        XCTAssertEqual(sut.comments, 2)
    }
    
    func testCommentValue() {
        XCTAssertEqual(sut.commentsValue, String())
        
        sut.post.numberOfComments = 2
        XCTAssertEqual(sut.commentsValue, String(2))
    }
    
    func testEdited() {
        XCTAssertTrue(sut.edited)
    }
    
    func testImageUrl() {
        XCTAssertEqual(sut.imageUrl, [URL(string: "https://image_url1.com"), URL(string: "https://image_url2.com")])
    }
    
    func testLink() {
        XCTAssertNil(sut.linkUrl)
    }
    
    func testLikes() {
        sut.post.likes = 5
        XCTAssertEqual(sut.likes, 5)
    }
    
    func testLikesText() {
        XCTAssertEqual(sut.likesText, String())
        
        sut.post.likes = 3
        XCTAssertEqual(sut.likesText, String(3))
    }
    
    func testReference() {
        XCTAssertEqual(sut.reference, .citation)

        sut.post.reference = ReferenceKind.link
        
        XCTAssertEqual(sut.reference, .link)
    }
    
    func testImageKind() {
        XCTAssertEqual(sut.kind, .two)
    }
}

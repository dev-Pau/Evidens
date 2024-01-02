//
//  EditPostViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 19/9/23.
//

import XCTest
import Firebase

@testable import Evidens

final class EditPostViewModelTests: XCTestCase {
    
    var sut: EditPostViewModel!
    
    override func setUpWithError() throws {
        
        let postData: [String: Any] = [
            "post": "This is a test post",
            "uid": "testUID",
            "timestamp": Timestamp(date: Date()),
            "kind": 1,
            "disciplines": [2, 3],
            "privacy": 1,
            "visible": 2,
            "imageUrl": ["image_url1", "image_url2"],
            "reference": 1,
            "edited": true,
            "hashtags": ["#test1", "#test2"]
        ]
        
        let post = Post(postId: "testPostId", dictionary: postData)
        
        sut = EditPostViewModel(post: post)
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testPostId() {
        XCTAssertEqual(sut.postId, "testPostId")
    }
    
    func testKind() {
        XCTAssertEqual(sut.kind, .image)
    }
    
    func testEditText() {
        let newPostContent = "Updated post content"
        sut.edit(newPostContent)
        XCTAssertEqual(newPostContent, "Updated post content")
    }
    
    func testEditHashtags() {
        let hashtags = ["Swift", "iOS", "Programming"]
        sut.set(hashtags)
    }
    
    func testSetLinks() {
        let links = ["www.evidens.app", "www.evidens.com"]
        sut.setLinks(links)
        XCTAssertEqual(sut.links, links)
    }
    
    func testLinksLoaded() {
        XCTAssertFalse(sut.linkLoaded)
    }
}

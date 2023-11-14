//
//  PostTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 18/9/23.
//

import XCTest
import Firebase
@testable import Evidens

final class PostTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testPost_WhenPostIsInitialized_ValuesShouldMatch() {
        let postDict: [String: Any] = [
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
        
        let post = Post(postId: "testPostID", dictionary: postDict)
        
        XCTAssertEqual(post.postId, "testPostID")
        XCTAssertEqual(post.postText, "This is a test post")
        XCTAssertEqual(post.uid, "testUID")
        XCTAssertNotNil(post.timestamp)
        XCTAssertEqual(post.kind, .image)
        XCTAssertEqual(post.disciplines, [.pharmacy, .physiotherapy])
        XCTAssertEqual(post.privacy, .regular)
        XCTAssertEqual(post.visible, .regular)
        XCTAssertEqual(post.imageUrl, ["image_url1", "image_url2"])
        XCTAssertEqual(post.reference, .citation)
        XCTAssertTrue(post.edited ?? false)
        XCTAssertEqual(post.hashtags, ["#test1", "#test2"])
    }
}

//
//  EditPostViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 19/9/23.
//

import XCTest
@testable import Evidens

final class EditPostViewModelTests: XCTestCase {

    var sut: EditPostViewModel!
    
    override func setUpWithError() throws {
        sut = EditPostViewModel(post: "Initial post content", postId: "postId")
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testEditPostViewModel_WhenTextHasChanged_ShouldReturnNewText() {
        let newPostContent = "Updated post content"
        sut.edit(newPostContent)
        XCTAssertEqual(newPostContent, "Updated post content")
    }
    
    func testEditPostViewModel_WhenSetHashtags_ShouldReturnHashtags() {
        let hashtags = ["Swift", "iOS", "Programming"]
        sut.set(hashtags)
        XCTAssertEqual(sut.hashtags, hashtags.map { $0.lowercased() })
    }
}

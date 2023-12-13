//
//  PostPrivacyTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class PostPrivacyTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testPostPrivacyTitle() {
        XCTAssertEqual(PostPrivacy.regular.title, AppStrings.Content.Post.Privacy.publicTitle)
    }
    
    func testPostPrivacyContent() {
        XCTAssertEqual(PostPrivacy.regular.content, AppStrings.Content.Post.Privacy.publicContent)
    }
    
    func testPostPrivacyImage() {
        let privacyImage = PostPrivacy.regular.image
        XCTAssertNotNil(privacyImage)
    }
}

//
//  CommentSourceTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class CommentSourceTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCommentSourceTitle() {
        XCTAssertEqual(CommentSource.post.title, AppStrings.Content.Post.post.lowercased())
        XCTAssertEqual(CommentSource.clinicalCase.title, AppStrings.Title.clinicalCase.lowercased())
    }
}

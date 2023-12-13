//
//  CommentKindTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class CommentKindTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCommentKindTitle() {
        XCTAssertEqual(CommentKind.comment.title, AppStrings.Profile.Comment.commented)
        XCTAssertEqual(CommentKind.reply.title, AppStrings.Profile.Comment.replied)
    }
}

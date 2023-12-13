//
//  CommentMenuTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class CommentMenuTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCommentMenuTitle() {
        XCTAssertEqual(CommentMenu.back.title, AppStrings.Menu.goBack)
        XCTAssertEqual(CommentMenu.report.title, AppStrings.Menu.reportComment)
        XCTAssertEqual(CommentMenu.delete.title, AppStrings.Menu.deleteComment)
    }
    
    func testCommentMenuImage() {

        let backImage = CommentMenu.back.image
        let reportImage = CommentMenu.report.image
        let deleteImage = CommentMenu.delete.image

        XCTAssertNotNil(backImage)
        XCTAssertNotNil(reportImage)
        XCTAssertNotNil(deleteImage)
    }
}

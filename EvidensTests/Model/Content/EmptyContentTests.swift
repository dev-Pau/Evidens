//
//  EmptyContentTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 12/12/23.
//

import XCTest
@testable import Evidens

final class EmptyContentTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLearnCaseTitle() {
        XCTAssertEqual(EmptyContent.learn.title, AppStrings.Content.Empty.learn)
    }
    
    func testDismissCaseTitle() {
        XCTAssertEqual(EmptyContent.dismiss.title, AppStrings.Content.Empty.dismiss)
    }
    
    func testRemoveCaseTitle() {
        XCTAssertEqual(EmptyContent.remove.title, AppStrings.Content.Empty.remove)
    }
    
    func testCommentCaseTitle() {
        XCTAssertEqual(EmptyContent.comment.title, AppStrings.Content.Empty.comment)
    }
}

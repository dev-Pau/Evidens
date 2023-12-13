//
//  DisplayContentTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 12/12/23.
//

import XCTest
@testable import Evidens

final class DisplayContentTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testJoinTitle() {
        let displayContent = DisplayContent.join
        XCTAssertEqual(displayContent.title, AppStrings.Display.joinTitle)
    }
    
    func testJoinDescription() {
        let displayContent = DisplayContent.join
        XCTAssertEqual(displayContent.description, AppStrings.Display.joinContent)
    }
    
    func testEmailTitle() {
        let displayContent = DisplayContent.email
        XCTAssertEqual(displayContent.title, AppStrings.Display.emailChangeTitle)
    }
    
    func testEmailDescription() {
        let displayContent = DisplayContent.email
        XCTAssertEqual(displayContent.description, AppStrings.Display.emailChangeContent)
    }
    
    func testPasswordTitle() {
        let displayContent = DisplayContent.password
        XCTAssertEqual(displayContent.title, AppStrings.Display.passwordChangeTitle)
    }
    
    func testPasswordDescription() {
        let displayContent = DisplayContent.password
        XCTAssertEqual(displayContent.description, AppStrings.Display.passwordChangeContent)
    }
    
    func testCommentTitle() {
        let displayContent = DisplayContent.comment
        XCTAssertEqual(displayContent.title, AppStrings.Display.commentTitle)
    }
    
    func testCommentDescription() {
        let displayContent = DisplayContent.comment
        XCTAssertEqual(displayContent.description, AppStrings.Display.commentContent)
    }
}

//
//  MessageSearchTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class MessageSearchTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testTitle() {
        XCTAssertEqual(MessageSearch.all.title, AppStrings.Content.Case.Filter.all)
        XCTAssertEqual(MessageSearch.conversation.title, AppStrings.Title.conversation)
        XCTAssertEqual(MessageSearch.messages.title, AppStrings.Title.message)
    }
}

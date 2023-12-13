//
//  MessageMenuTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class MessageMenuTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testLabel() {
        XCTAssertEqual(MessageMenu.share.label, AppStrings.Menu.sharePhoto)
        XCTAssertEqual(MessageMenu.copy.label, AppStrings.Menu.copy)
        XCTAssertEqual(MessageMenu.delete.label, AppStrings.Menu.deleteMessage)
        XCTAssertEqual(MessageMenu.resend.label, AppStrings.Menu.resendMessage)
    }
    
    func testImage() {
        XCTAssertNotNil(MessageMenu.share.image)
        XCTAssertNotNil(MessageMenu.copy.image)
        XCTAssertNotNil(MessageMenu.delete.image)
        XCTAssertNotNil(MessageMenu.resend.image)
    }
    
}

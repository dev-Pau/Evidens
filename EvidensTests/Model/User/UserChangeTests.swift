//
//  UserChangeTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class UserChangeTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testTitle() {
        XCTAssertEqual(UserChange.email.title, AppStrings.User.Changes.email)
        XCTAssertEqual(UserChange.password.title, AppStrings.User.Changes.password)
        XCTAssertEqual(UserChange.deactivate.title, AppStrings.User.Changes.deactivate)
    }
    
    func testContent() {
        XCTAssertEqual(UserChange.email.content, AppStrings.User.Changes.emailContent)
        XCTAssertEqual(UserChange.password.content, AppStrings.User.Changes.passwordContent)
        XCTAssertEqual(UserChange.deactivate.content, AppStrings.User.Changes.deactivateContent)
    }
    
    func testHint() {
        XCTAssertEqual(UserChange.email.hint, AppStrings.Miscellaneous.great)
        XCTAssertEqual(UserChange.password.hint, AppStrings.Miscellaneous.great)
        XCTAssertEqual(UserChange.deactivate.hint, AppStrings.Miscellaneous.gotIt)
    }
}

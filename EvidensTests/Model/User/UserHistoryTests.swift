//
//  UserHistoryTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class UserHistoryTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testPath() {
        XCTAssertEqual(UserHistory.logIn.path, AppStrings.User.Changes.login)
        XCTAssertEqual(UserHistory.phase.path, AppStrings.User.Changes.phase)
        XCTAssertEqual(UserHistory.password.path, AppStrings.User.Changes.pass)
    }
}

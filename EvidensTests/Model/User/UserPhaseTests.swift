//
//  UserPhaseTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class UserPhaseTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testContent() {
        XCTAssertEqual(UserPhase.category.content, "")
        XCTAssertEqual(UserPhase.name.content, "")
        XCTAssertEqual(UserPhase.username.content, "")
        XCTAssertEqual(UserPhase.identity.content, AppStrings.User.Changes.identity)
        XCTAssertEqual(UserPhase.pending.content, AppStrings.User.Changes.pending)
        XCTAssertEqual(UserPhase.review.content, AppStrings.User.Changes.review)
        XCTAssertEqual(UserPhase.verified.content, AppStrings.User.Changes.verified)
        XCTAssertEqual(UserPhase.deactivate.content, "")
        XCTAssertEqual(UserPhase.ban.content, "")
    }
}

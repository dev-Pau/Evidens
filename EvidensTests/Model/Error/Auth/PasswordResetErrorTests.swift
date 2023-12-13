//
//  PasswordResetErrorTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 12/12/23.
//

import XCTest
@testable import Evidens

final class PasswordResetErrorTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testInvalidEmailError() {
        let error = PasswordResetError.invalidEmail
        XCTAssertEqual(error.title, AppStrings.Error.title)
        XCTAssertEqual(error.content, AppStrings.Error.emailFormat)
    }
    
    func testNetworkError() {
        let error = PasswordResetError.network
        XCTAssertEqual(error.title, AppStrings.Error.title)
        XCTAssertEqual(error.content, AppStrings.Error.network)
    }
    
    func testUserNotFoundError() {
        let error = PasswordResetError.userNotFound
        XCTAssertEqual(error.title, AppStrings.Error.title)
        XCTAssertEqual(error.content, AppStrings.Error.userNotFound)
    }
    
    func testUnknownError() {
        let error = PasswordResetError.unknown
        XCTAssertEqual(error.title, AppStrings.Error.title)
        XCTAssertEqual(error.content, AppStrings.Error.unknown)
    }
}

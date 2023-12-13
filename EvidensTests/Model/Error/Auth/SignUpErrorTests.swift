//
//  SignUpErrorTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 12/12/23.
//

import XCTest
@testable import Evidens

final class SignUpErrorTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testNetworkError() {
        let error = SignUpError.network
        XCTAssertEqual(error.title, AppStrings.Error.title)
        XCTAssertEqual(error.content, AppStrings.Error.network)
    }
    
    func testUserFoundError() {
        let error = SignUpError.userFound
        XCTAssertEqual(error.title, AppStrings.Error.title)
        XCTAssertEqual(error.content, AppStrings.Error.userFound)
    }
    
    func testInvalidEmailError() {
        let error = SignUpError.invalidEmail
        XCTAssertEqual(error.title, AppStrings.Error.title)
        XCTAssertEqual(error.content, AppStrings.Error.emailFormat)
    }
    
    func testWeakPasswordError() {
        let error = SignUpError.weakPassword
        XCTAssertEqual(error.title, AppStrings.Error.title)
        XCTAssertEqual(error.content, AppStrings.Error.weakPassword)
    }
    
    func testUnknownError() {
        let error = SignUpError.unknown
        XCTAssertEqual(error.title, AppStrings.Error.title)
        XCTAssertEqual(error.content, AppStrings.Error.unknown)
    }
}

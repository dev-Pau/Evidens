//
//  LoginEmailViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 14/9/23.
//

import XCTest
@testable import Evidens

final class LoginEmailViewModelTests: XCTestCase {
    
    var sut: LoginEmailViewModel!

    override func setUpWithError() throws {
        sut = LoginEmailViewModel()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    
    func testLoginEmailViewModel_WhenEmailIsNil_ExpectTrue() {
        sut.set(email: nil)
        
        XCTAssertTrue(sut.isEmailEmpty())
    }


    func testLoginEmailViewModel_WhenEmailIsEmptyString_ExpectTrue() {
        sut.set(email: "")
        
        XCTAssertTrue(sut.isEmailEmpty())
    }


    func testLoginEmailViewModel_WhenEmailIsNotEmpty_ExpectFalse() {
        sut.set(email: "evidens@evidens.com")
        
        XCTAssertFalse(sut.isEmailEmpty())
    }

    func testIsEmailEmpty_WhenEmailIsWhitespace_ExpectTrue() {
        sut.set(email: "   ")
        
        XCTAssertTrue(sut.isEmailEmpty())
    }
}

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
    
    func testNilEmail() {
        sut.set(email: nil)
        
        XCTAssertTrue(sut.isEmailEmpty())
    }

    func testEmptyEmail() {
        sut.set(email: "")
        
        XCTAssertTrue(sut.isEmailEmpty())
    }

    func testValidEmail() {
        sut.set(email: "evidens@evidens.com")
        
        XCTAssertFalse(sut.isEmailEmpty())
    }

    func testWhitespaceEmail() {
        sut.set(email: "   ")
        
        XCTAssertTrue(sut.isEmailEmpty())
    }
}

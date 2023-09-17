//
//  EmailRegistrationViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 14/9/23.
//

import XCTest

@testable import Evidens

final class EmailRegistrationViewModelTests: XCTestCase {
    
    var sut: EmailRegistrationViewModel!
    
    override func setUpWithError() throws {
        sut = EmailRegistrationViewModel()
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testEmailRegistrationViewModel_WhenEmailIsValid_ExpectTrue() {
        sut.email = "evidens@evidens.com"
        XCTAssertTrue(sut.emailIsValid)
    }
    
    func testEmailRegistrationViewModel_WhenEmailIsInvalid_ExpectFalse() {
        sut.email = "invalid-email"
        XCTAssertFalse(sut.emailIsValid)
    }
    
    func testEmailRegistrationViewModel_WhenEmailIsNil_ExpectTrue() {
        XCTAssertTrue(sut.emailIsEmpty)
    }
    
    func testEmailRegistrationViewModel_WhenEmailIsEmptyString_ExpectTrue() {
        sut.email = ""
        XCTAssertTrue(sut.emailIsEmpty)
    }
    
    func testEmailRegistrationViewModel_WhenEmailIsWhitespace_ExpectTrue() {
        sut.email = "   "
        XCTAssertTrue(sut.emailIsEmpty)
    }
    
    func testEmailRegistrationViewModel_WhenEmailIsNotEmpty_ExpectFalse() {
        sut.email = "evidens@evidens.com"
        XCTAssertFalse(sut.emailIsEmpty)
    }
}

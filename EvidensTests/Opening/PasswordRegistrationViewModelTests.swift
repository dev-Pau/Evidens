//
//  PasswordRegistrationViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 14/9/23.
//

import XCTest
@testable import Evidens

final class PasswordRegistrationViewModelTests: XCTestCase {
    
    var sut: PasswordRegistrationViewModel!
    
    override func setUpWithError() throws {
        sut = PasswordRegistrationViewModel()
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testPasswordRegistrationViewModel_WhenPasswordIsNil_ExpectTrue() {
        XCTAssertTrue(sut.passwordIsEmpty)
    }
    
    func testPasswordRegistrationViewModel_WhenPasswordIsEmptyString_ExpectTrue() {
        sut.password = ""
        XCTAssertTrue(sut.passwordIsEmpty)
    }
    
    func testPasswordRegistrationViewModel_WhenPasswordIsNotEmpty_ExpectFalse() {
        sut.password = "password123"
        XCTAssertFalse(sut.passwordIsEmpty)
    }
    
    func testPasswordRegistrationViewModel_WhenPasswordIsLessThan8Characters_ExpectFalse() {
        sut.password = "abc123"
        XCTAssertFalse(sut.passwordMinChar)
    }
    
    func testPasswordRegistrationViewModel_WhenPasswordIsExactly8Characters_ExpectTrue() {
        sut.password = "abcdefg1"
        XCTAssertTrue(sut.passwordMinChar)
    }
    
    func testPasswordRegistrationViewModel_WhenPasswordIsMoreThan8Characters_ExpectTrue() {
        sut.password = "abcdefghi1"
        XCTAssertTrue(sut.passwordMinChar)
    }
    
    func testPasswordRegistrationViewModel_WhenPasswordIsLessThan8Characters_ExpectIsValidFalse() {
        sut.password = "abc123"
        XCTAssertFalse(sut.passwordIsValid)
    }
    
    func testPasswordRegistrationViewModel_WhenPasswordIsExactly8Characters_ExpectIsValidTrue() {
        sut.password = "abcdefg1"
        XCTAssertTrue(sut.passwordIsValid)
    }
    
    func testPasswordRegistrationViewModel_WhenPasswordIsMoreThan8Characters_ExpectIsValidTrue() {
        sut.password = "abcdefghi1"
        XCTAssertTrue(sut.passwordIsValid)
    }
    
    func testPasswordRegistrationViewModel_WhenPasswordIsLessThan8Characters_ExpectFormIsValidFalse() {
        sut.password = "abc123"
        XCTAssertFalse(sut.formIsValid)
    }
    
    func testPasswordRegistrationViewModel_WhenPasswordIsExactly8Characters_ExpectFormIsValidTrue() {
        sut.password = "abcdefg1"
        XCTAssertTrue(sut.formIsValid)
    }
    
    func testPasswordRegistrationViewModel_WhenPasswordIsMoreThan8Characters_ExpectFormIsValidTrue() {
        sut.password = "abcdefghi1"
        XCTAssertTrue(sut.formIsValid)
    }
}

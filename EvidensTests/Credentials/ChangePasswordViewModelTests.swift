//
//  ChangePasswordViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 15/9/23.
//

import XCTest
@testable import Evidens

final class ChangePasswordViewModelTests: XCTestCase {
    
    var sut: ChangePasswordViewModel!
    
    override func setUpWithError() throws {
        sut = ChangePasswordViewModel()
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testChangePasswordViewModel_WhenAllFieldsAreEmpty_ExpectFalse() {
        XCTAssertFalse(sut.formIsValid)
    }
    
    func testChangePasswordViewModel_WhenCurrentPasswordIsEmpty_ExpectFalse() {
        sut.newPassword = "newPassword123"
        sut.confirmPassword = "newPassword123"
        XCTAssertFalse(sut.formIsValid)
    }
    
    func testChangePasswordViewModel_WhenNewPasswordIsEmpty_ExpectFalse() {
        sut.currentPassword = "currentPassword"
        sut.confirmPassword = "currentPassword"
        XCTAssertFalse(sut.formIsValid)
    }
    
    func testChangePasswordViewModel_WhenConfirmPasswordIsEmpty_ExpectFalse() {
        sut.currentPassword = "currentPassword"
        sut.newPassword = "newPassword123"
        XCTAssertFalse(sut.formIsValid)
    }

    func testChangePasswordViewModel_WhenAllFieldsAreNonEmpty_ExpectTrue() {
        sut.currentPassword = "currentPassword"
        sut.newPassword = "newPassword123"
        sut.confirmPassword = "newPassword123"
        XCTAssertTrue(sut.formIsValid)
    }

    func testChangePasswordViewModel_WhenPasswordsDoNotMatch_ExpectFalse() {
        sut.newPassword = "newPassword123"
        sut.confirmPassword = "password456"
        XCTAssertFalse(sut.newPasswordMatch)
    }

    func testChangePasswordViewModel_WhenPasswordsMatch_ExpectTrue() {
        sut.newPassword = "newPassword123"
        sut.confirmPassword = "newPassword123"
        XCTAssertTrue(sut.newPasswordMatch)
    }

    func testChangePasswordViewModel_WhenPasswordIsShorterThan8Characters_ExpectFalse() {
        sut.newPassword = "abc123"
        XCTAssertFalse(sut.newPasswordMinLength)
    }

    func testChangePasswordViewModel_WhenPasswordIsAtLeast8Characters_ExpectTrue() {
        sut.newPassword = "password1"
        XCTAssertTrue(sut.newPasswordMinLength)
    }
}

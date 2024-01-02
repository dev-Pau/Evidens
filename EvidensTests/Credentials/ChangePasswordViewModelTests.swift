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
    
    func testChangePasswordWithEmptyFields() {
        XCTAssertFalse(sut.formIsValid)
    }
    
    func testChangePasswordWithEmptyPassword() {
        sut.newPassword = "newPassword123"
        sut.confirmPassword = "newPassword123"
        XCTAssertFalse(sut.formIsValid)
    }
    
    func testChangePasswordWithEmptyCurrentPassword() {
        sut.currentPassword = "currentPassword"
        sut.confirmPassword = "currentPassword"
        XCTAssertFalse(sut.formIsValid)
    }
    
    func testChangePasswordWithEmptyConfirmPassword() {
        sut.currentPassword = "currentPassword"
        sut.newPassword = "newPassword123"
        XCTAssertFalse(sut.formIsValid)
    }

    func testChangePasswordWithValidFields() {
        sut.currentPassword = "currentPassword"
        sut.newPassword = "newPassword123"
        sut.confirmPassword = "newPassword123"
        XCTAssertTrue(sut.formIsValid)
    }

    func testChangePasswordWithIncorretPasswords() {
        sut.newPassword = "newPassword123"
        sut.confirmPassword = "password456"
        XCTAssertFalse(sut.newPasswordMatch)
    }

    func testChangePasswordWithCorrectPasswords() {
        sut.newPassword = "newPassword123"
        sut.confirmPassword = "newPassword123"
        XCTAssertTrue(sut.newPasswordMatch)
    }

    func testChangePasswordWithShortPassword() {
        sut.newPassword = "abc123"
        XCTAssertFalse(sut.newPasswordMinLength)
    }

    func testChangePasswordWithLongPassword() {
        sut.newPassword = "password1"
        XCTAssertTrue(sut.newPasswordMinLength)
    }
}

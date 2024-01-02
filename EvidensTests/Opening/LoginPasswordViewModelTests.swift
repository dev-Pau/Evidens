//
//  LoginPasswordViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 14/9/23.
//

import XCTest
@testable import Evidens

final class LoginPasswordViewModelTests: XCTestCase {
    
    var sut: LoginPasswordViewModel!
    
    override func setUpWithError() throws {
        sut = LoginPasswordViewModel()
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testNilPassword() {
        sut.set(password: nil)
        
        XCTAssertTrue(sut.isPasswordEmpty())
    }
    
    func testEmptyPassword() {
        _ = LoginPasswordViewModel()
        sut.set(password: "")
        
        XCTAssertTrue(sut.isPasswordEmpty())
    }
    
    func testValidPassword() {
        sut.set(password: "password123")
        
        XCTAssertFalse(sut.isPasswordEmpty())
    }
}

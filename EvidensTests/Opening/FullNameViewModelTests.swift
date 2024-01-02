//
//  FullNameViewModel.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 15/9/23.
//

import XCTest
@testable import Evidens

final class FullNameViewModelTests: XCTestCase {
    
    var sut: FullNameViewModel!
    
    override func setUpWithError() throws {
        sut = FullNameViewModel()
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testNilFirstName() {
        XCTAssertFalse(sut.firstNameIsValid)
    }
    
    func testEmptyFirstName() {
        sut.set(firstName: "")
        XCTAssertFalse(sut.firstNameIsValid)
    }
    
    func testWhitespaceFirstName() {
        sut.set(firstName: "   ")
        XCTAssertFalse(sut.firstNameIsValid)
    }
    
    func testValidFirstName() {
        sut.set(firstName: "John")
        XCTAssertTrue(sut.firstNameIsValid)
    }
    
    func testNilLastName() {
        XCTAssertFalse(sut.lastNameIsValid)
    }
    
    func testEmptyLastName() {
        sut.set(lastName: "")
        XCTAssertFalse(sut.lastNameIsValid)
    }

    func testWhitespaceLastName() {
        sut.set(lastName: "   ")
        XCTAssertFalse(sut.lastNameIsValid)
    }

    func testValidLastName() {
        sut.set(lastName: "Doe")
        XCTAssertTrue(sut.lastNameIsValid)
    }

    func testInvalidForm() {
        XCTAssertFalse(sut.formIsValid)
    }

    func testInvalidFirstNameForm() {
        sut.set(lastName: "Doe")
        XCTAssertFalse(sut.formIsValid)
    }

    func testInvalidLastNameForm() {
        sut.set(firstName: "John")
        XCTAssertFalse(sut.formIsValid)
    }

    func testValidForm() {
        sut.set(firstName: "John")
        sut.set(lastName: "Doe")
        XCTAssertTrue(sut.formIsValid)
    }
}

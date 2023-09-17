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
    
    func testFullNameViewModel_WhenFirstNameIsNil_ExpectFalse() {
        XCTAssertFalse(sut.firstNameIsValid)
    }
    
    func testFullNameViewModel_WhenFirstNameIsEmptyString_ExpectFalse() {
        sut.set(firstName: "")
        XCTAssertFalse(sut.firstNameIsValid)
    }
    
    func testFullNameViewModel_WhenFirstNameIsWhitespace_ExpectFalse() {
        sut.set(firstName: "   ")
        XCTAssertFalse(sut.firstNameIsValid)
    }
    
    func testFirstNameIsValid_WhenFirstNameIsNotEmpty_ExpectTrue() {
        sut.set(firstName: "John")
        XCTAssertTrue(sut.firstNameIsValid)
    }
    
    func testLastNameIsValid_WhenLastNameIsNil_ExpectFalse() {
        XCTAssertFalse(sut.lastNameIsValid)
    }
    
    func testLastNameIsValid_WhenLastNameIsEmptyString_ExpectFalse() {
        sut.set(lastName: "")
        XCTAssertFalse(sut.lastNameIsValid)
    }

    func testLastNameIsValid_WhenLastNameIsWhitespace_ExpectFalse() {
        sut.set(lastName: "   ")
        XCTAssertFalse(sut.lastNameIsValid)
    }

    func testLastNameIsValid_WhenLastNameIsNotEmpty_ExpectTrue() {
        sut.set(lastName: "Doe")
        XCTAssertTrue(sut.lastNameIsValid)
    }

    func testFormIsValid_WhenBothFirstNameAndLastNameAreEmpty_ExpectFalse() {
        XCTAssertFalse(sut.formIsValid)
    }

    func testFormIsValid_WhenFirstNameIsEmpty_ExpectFalse() {
        sut.set(lastName: "Doe")
        XCTAssertFalse(sut.formIsValid)
    }

    func testFormIsValid_WhenLastNameIsEmpty_ExpectFalse() {
        sut.set(firstName: "John")
        XCTAssertFalse(sut.formIsValid)
    }

    func testFormIsValid_WhenBothFirstNameAndLastNameAreNotEmpty_ExpectTrue() {
        sut.set(firstName: "John")
        sut.set(lastName: "Doe")
        XCTAssertTrue(sut.formIsValid)
    }
}

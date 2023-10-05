//
//  AddCaseRevisionViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 19/9/23.
//

import XCTest
@testable import Evidens

final class AddCaseRevisionViewModelTests: XCTestCase {
    
    var sut: AddCaseRevisionViewModel!
    
    override func setUpWithError() throws {
        sut = AddCaseRevisionViewModel(clinicalCase: Case(caseId: "", dictionary: [:]))
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testCaseRevisionViewModel_WhenBothTitleAndContentNotEmpty_ShouldReturnTrue() {
        sut.title = "Valid Title"
        sut.content = "Valid Content"
        XCTAssertTrue(sut.isValid)
    }
    
    func testCaseRevisionViewModel_WhenTitleIsEmptyButContentNotEmpty_ShouldReturnFalse() {
        sut.title = ""
        sut.content = "Valid Content"
        XCTAssertFalse(sut.isValid)
    }
    
    func testCaseRevisionViewModel_WhenTitleIsNotEmptyButContentIsEmpty_ShouldReturnFalse() {
        sut.title = "Valid Title"
        sut.content = ""
        XCTAssertFalse(sut.isValid)
    }
    
    func testCaseRevisionViewModel_WhenBothTitleAndContentAreEmpty_ShouldReturnFalse() {
        sut.title = ""
        sut.content = ""
        XCTAssertFalse(sut.isValid)
    }
}

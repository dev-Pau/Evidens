//
//  CaseRevisionViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 19/9/23.
//

import XCTest
@testable import Evidens

final class CaseRevisionViewModelTests: XCTestCase {
    
    var sut: CaseRevisionViewModel!
    
    override func setUpWithError() throws {
        sut = CaseRevisionViewModel()
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

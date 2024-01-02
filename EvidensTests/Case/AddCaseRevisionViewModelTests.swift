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
    
    func testValidRevision() {
        sut.title = "Valid Title"
        sut.content = "Valid Content"
        XCTAssertTrue(sut.isValid)
    }
    
    func testInvalidTitle() {
        sut.title = ""
        sut.content = "Valid Content"
        XCTAssertFalse(sut.isValid)
    }
    
    func testInvalidContent() {
        sut.title = "Valid Title"
        sut.content = ""
        XCTAssertFalse(sut.isValid)
    }
    
    func testInvaludValues() {
        sut.title = ""
        sut.content = ""
        XCTAssertFalse(sut.isValid)
    }
}

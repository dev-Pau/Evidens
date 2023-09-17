//
//  EducationViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 15/9/23.
//

import XCTest
@testable import Evidens

final class EducationViewModelTests: XCTestCase {
    
    var sut: EducationViewModel!
    
    override func setUpWithError() throws {
        sut = EducationViewModel()
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testEducationViewModel_WhenSchoolKindFieldStartAndEndAreNil_ReturnsFalse() {
        XCTAssertFalse(sut.isValid)
    }
    
    func testEducationViewModel_WhenSchoolIsNotNilAndKindIsNil_ReturnsFalse() {
        sut.set(school: "Sample School")
        XCTAssertFalse(sut.isValid)
    }
    
    func testEducationViewModel_WhenSchoolIsNilAndKindIsNotNil_ReturnsFalse() {
        sut.set(kind: "Bachelor's")
        XCTAssertFalse(sut.isValid)
    }
    
    func testEducationViewModel_WhenSchoolKindFieldStartAndEndAreNotNil_ReturnsTrue() {
        sut.set(school: "Sample School")
        sut.set(kind: "Bachelor's")
        sut.set(field: "Computer Science")
        sut.set(start: Date().timeIntervalSince1970)
        sut.set(end: Date().timeIntervalSince1970 + 3600)
        XCTAssertTrue(sut.isValid)
    }
    
    func testEducationViewModel_SetsAllProperties_ShouldReturnEqualProperties() {
        let education = Education(id: "123", school: "Sample School", kind: "Master's", field: "Data Science", start: Date().timeIntervalSince1970, end: Date().timeIntervalSince1970 + 3600)
        sut.set(education: education)
        
        XCTAssertEqual(sut.id, "123")
        XCTAssertEqual(sut.school, "Sample School")
        XCTAssertEqual(sut.kind, "Master's")
        XCTAssertEqual(sut.field, "Data Science")
        XCTAssertNotNil(sut.start)
        XCTAssertNotNil(sut.end)
    }
    
    func testEducationViewModel_WhenSetsSchool_ShouldReturnSameSchool() {
        sut.set(school: "New School")
        XCTAssertEqual(sut.school, "New School")
    }
    
    func testEducationViewModel_WhenSetsKind_ShouldReturnSameKind() {
        sut.set(kind: "Ph.D.")
        XCTAssertEqual(sut.kind, "Ph.D.")
    }
    
    func testEducationViewModel_WhenSetsField_ShouldReturnSameField() {
        sut.set(field: "Chemistry")
        XCTAssertEqual(sut.field, "Chemistry")
    }
    
    func testEducationViewModel_WhenSetsStart_ShouldReturnSameDate() {
        let start = Date().timeIntervalSince1970
        sut.set(start: start)
        XCTAssertEqual(sut.start, start)
    }
    
    func testEducationViewModel_WhenSetsEnd_ShouldReturnEndDate() {
        let end = Date().timeIntervalSince1970
        sut.set(end: end)
        XCTAssertEqual(sut.end, end)
    }
    
    func testEducationViewModel_WhenAllPropertiesAreNil_ReturnsNil() {
        XCTAssertNil(sut.education)
    }
}

//
//  ExperienceViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 15/9/23.
//

import XCTest
@testable import Evidens

final class ExperienceViewModelTests: XCTestCase {
    
    var sut: ExperienceViewModel!
    
    override func setUpWithError() throws {
        sut = ExperienceViewModel()
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testExperienceViewModel_WhenRoleCompanyStartAndEndAreNil_ReturnsFalse() {
        XCTAssertFalse(sut.isValid)
    }
    
    func testExperienceViewModel_WhenRoleIsNotNilAndCompanyIsNil_ReturnsFalse() {
        sut.set(role: "Software Engineer")
        XCTAssertFalse(sut.isValid)
    }
    
    func testExperienceViewModel_WhenRoleIsNilAndCompanyIsNotNil_ReturnsFalse() {
        sut.set(company: "ABC Inc.")
        XCTAssertFalse(sut.isValid)
    }
    
    func testExperienceViewModel_WhenRoleCompanyStartAndEndAreNotNil_ReturnsTrue() {
        sut.set(role: "Software Engineer")
        sut.set(company: "ABC Inc.")
        sut.set(start: Date().timeIntervalSince1970)
        sut.set(end: Date().timeIntervalSince1970 + 3600) // Adding 1 hour
        XCTAssertTrue(sut.isValid)
    }
    
    func testExperienceViewModel_SetsAllProperties() {
        let experience = Experience(id: "123", role: "Software Engineer", company: "ABC Inc.", start: Date().timeIntervalSince1970, end: Date().timeIntervalSince1970 + 3600)
        sut.set(experience: experience)
        
        XCTAssertEqual(sut.id, "123")
        XCTAssertEqual(sut.role, "Software Engineer")
        XCTAssertEqual(sut.company, "ABC Inc.")
        XCTAssertNotNil(sut.start)
        XCTAssertNotNil(sut.end)
    }
    
    func testExperienceViewModel_SetsRole() {
        sut.set(role: "Product Manager")
        XCTAssertEqual(sut.role, "Product Manager")
    }
    
    func testExperienceViewModel_SetsCompany() {
        sut.set(company: "XYZ Corp.")
        XCTAssertEqual(sut.company, "XYZ Corp.")
    }
    
    func testExperienceViewModel_SetsStart() {
        let start = Date().timeIntervalSince1970
        sut.set(start: start)
        XCTAssertEqual(sut.start, start)
    }
    
    func testExperienceViewModel_SetsEnd() {
        let end = Date().timeIntervalSince1970
        sut.set(end: end)
        XCTAssertEqual(sut.end, end)
    }
    
    func testExperienceViewModel_WhenAllPropertiesAreNil_ReturnsNil() {
        XCTAssertNil(sut.experience)
    }
}

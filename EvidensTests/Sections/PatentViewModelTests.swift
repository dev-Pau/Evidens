//
//  PatentViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 15/9/23.
//

import XCTest
@testable import Evidens

final class PatentViewModelTests: XCTestCase {
    
    var sut: PatentViewModel!
    
    override func setUpWithError() throws {
        sut = PatentViewModel()
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testPatentViewModel_WhenTitleCodeAndUidsAreNil_ReturnsFalse() {
        XCTAssertFalse(sut.isValid)
    }
    
    func testPatentViewModel_WhenTitleIsNotNilAndCodeIsNil_ReturnsFalse() {
        sut.set(title: "Sample Title")
        XCTAssertFalse(sut.isValid)
    }
    
    func testPatentViewModel_WhenTitleIsNilAndCodeIsNotNil_ReturnsFalse() {
        sut.set(code: "AB123")
        XCTAssertFalse(sut.isValid)
    }
    
    func testPatentViewModel_SetsAllProperties_ShouldAssignAllProperties() {
        let patent = Patent(id: "123", title: "Sample Title", code: "AB123", uids: ["uid1", "uid2"])
        sut.set(patent: patent)
        
        XCTAssertEqual(sut.id, "123")
        XCTAssertEqual(sut.title, "Sample Title")
        XCTAssertEqual(sut.code, "AB123")
        XCTAssertEqual(sut.uids, ["uid1", "uid2"])
    }
    
    func testPatentViewModel_WhenSetsTitle_ShouldAssignTitle() {
        sut.set(title: "New Title")
        XCTAssertEqual(sut.title, "New Title")
    }
    
    func testPatentViewModel_WhenSetsPatentCode_ShouldAssignCode() {
        sut.set(code: "XYZ789")
        XCTAssertEqual(sut.code, "XYZ789")
    }
    
    func testPatentViewModel_WhenAllPropertiesAreNil_ReturnsNil() {
        XCTAssertNil(sut.patent)
    }
}

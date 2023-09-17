//
//  LanguageViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 15/9/23.
//

import XCTest
@testable import Evidens

final class LanguageViewModelTests: XCTestCase {
    
    var sut: LanguageViewModel!
    
    override func setUpWithError() throws {
        sut = LanguageViewModel()
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testLanguageViewModel_WhenKindIsNil_ReturnsFalse() {
        XCTAssertFalse(sut.hasKind)
    }
    
    func testLanguageViewModel_WhenKindIsNotNil_ReturnsTrue() {
        sut.set(kind: .english)
        XCTAssertTrue(sut.hasKind)
    }
    
    func testLanguageViewModel_WhenProficiencyIsNil_ReturnsFalse() {
        XCTAssertFalse(sut.hasProficiency)
    }
    
    func testLanguageViewModel_WhenProficiencyIsNotNil_ReturnsTrue() {
        sut.set(proficiency: .advanced)
        XCTAssertTrue(sut.hasProficiency)
    }
    
    func testLanguageViewModel_WhenKindAndProficiencyAreNil_IsValidReturnsFalse() {
        XCTAssertFalse(sut.isValid)
    }
    
    func testLanguageViewModel_WhenKindIsNotNilAndProficiencyIsNil_IsValidReturnsFalse() {
        sut.set(kind: .english)
        XCTAssertFalse(sut.isValid)
    }
    
    func testLanguageViewModel_WhenKindIsNilAndProficiencyIsNotNil_IsValidReturnsFalse() {
        sut.set(proficiency: .advanced)
        XCTAssertFalse(sut.isValid)
    }
    
    func testLanguageViewModel_WhenKindAndProficiencyAreNotNil_IsValidReturnsTrue() {
        sut.set(kind: .english)
        sut.set(proficiency: .elementary)
        XCTAssertTrue(sut.isValid)
    }
    
    func testLanguageViewModel_WhenKindAndProficiencyAreNil_LanguageReturnsNil() {
        XCTAssertNil(sut.language)
    }
    
    func testLanguageViewModel_WhenKindIsNotNilAndProficiencyIsNil_LanguageReturnsNil() {
        sut.set(kind: .english)
        XCTAssertNil(sut.language)
    }
    
    func testLanguageViewModel_WhenKindIsNilAndProficiencyIsNotNil_LanguageReturnsNil() {
        sut.set(proficiency: .functionally)
        XCTAssertNil(sut.language)
    }
    
    func testLanguageViewModel_WhenKindAndProficiencyAreNotNil_ReturnsEqualLanguage() {
        sut.set(kind: .english)
        sut.set(proficiency: .elementary)
        
        let expectedLanguage = Language(kind: .english, proficiency: .elementary)
        XCTAssertEqual(sut.language, expectedLanguage)
    }
    
    func testLanguageViewModel_WhenSetsKindAndProficiency_LanguageShouldBeAssigned() {
        let language = Language(kind: .spanish, proficiency: .advanced)
        
        sut.set(language: language)
        
        XCTAssertEqual(sut.kind, .spanish)
        XCTAssertEqual(sut.proficiency, .advanced)
    }
}

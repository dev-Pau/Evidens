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
    
    func testNilKind() {
        XCTAssertFalse(sut.hasKind)
    }
    
    func testValidKind() {
        sut.set(kind: .english)
        XCTAssertTrue(sut.hasKind)
    }
    
    func testNilProficiency() {
        XCTAssertFalse(sut.hasProficiency)
    }
    
    func testValidProficiency() {
        sut.set(proficiency: .advanced)
        XCTAssertTrue(sut.hasProficiency)
    }
    
    func testNilValues() {
        XCTAssertFalse(sut.isValid)
    }
    
    func testValidValues() {
        sut.set(kind: .english)
        XCTAssertFalse(sut.isValid)
    }
    
    func testNilKindValidProficiency() {
        sut.set(proficiency: .advanced)
        XCTAssertFalse(sut.isValid)
    }
    
    func testValidLanguage() {
        sut.set(kind: .english)
        sut.set(proficiency: .elementary)
        XCTAssertTrue(sut.isValid)
    }
    
    func testBothNilValues() {
        XCTAssertNil(sut.language)
    }
    
    func testValidKindNilProficiency() {
        sut.set(kind: .english)
        XCTAssertNil(sut.language)
    }
    
    func testInvalidKind() {
        sut.set(proficiency: .functionally)
        XCTAssertNil(sut.language)
    }
    
    func testValidLanguageValues() {
        sut.set(kind: .english)
        sut.set(proficiency: .elementary)
        
        let expectedLanguage = Language(kind: .english, proficiency: .elementary)
        XCTAssertEqual(sut.language, expectedLanguage)
    }
    
    func testAssignLanguage() {
        let language = Language(kind: .spanish, proficiency: .advanced)
        
        sut.set(language: language)
        
        XCTAssertEqual(sut.kind, .spanish)
        XCTAssertEqual(sut.proficiency, .advanced)
    }
}

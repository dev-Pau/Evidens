//
//  LanguageKindTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 12/12/23.
//

import XCTest
@testable import Evidens

final class LanguageKindTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testNameEnglish() {
        let languageKind = LanguageKind.english
        XCTAssertEqual(languageKind.name, AppStrings.Sections.Language.english)
    }
    
    func testNameMandarin() {
        let languageKind = LanguageKind.mandarin
        XCTAssertEqual(languageKind.name, AppStrings.Sections.Language.mandarin)
    }
    
    func testNameHindi() {
        let languageKind = LanguageKind.hindi
        XCTAssertEqual(languageKind.name, AppStrings.Sections.Language.hindi)
    }
    
    func testNameSpanish() {
        let languageKind = LanguageKind.spanish
        XCTAssertEqual(languageKind.name, AppStrings.Sections.Language.spanish)
    }
    
    func testNameCatalan() {
        let languageKind = LanguageKind.catalan
        XCTAssertEqual(languageKind.name, AppStrings.Sections.Language.catalan)
    }
    
    func testNameFrench() {
        let languageKind = LanguageKind.french
        XCTAssertEqual(languageKind.name, AppStrings.Sections.Language.french)
    }
    
    func testNameBasque() {
        let languageKind = LanguageKind.basque
        XCTAssertEqual(languageKind.name, AppStrings.Sections.Language.basque)
    }
    
    func testNameAranese() {
        let languageKind = LanguageKind.aranese
        XCTAssertEqual(languageKind.name, AppStrings.Sections.Language.aranese)
    }
    
    func testNameRomanian() {
        let languageKind = LanguageKind.romanian
        XCTAssertEqual(languageKind.name, AppStrings.Sections.Language.romanian)
    }
    
    func testNameGalician() {
        let languageKind = LanguageKind.galician
        XCTAssertEqual(languageKind.name, AppStrings.Sections.Language.galician)
    }
    
    func testNameRussian() {
        let languageKind = LanguageKind.russian
        XCTAssertEqual(languageKind.name, AppStrings.Sections.Language.russian)
    }
    
    func testNamePortuguese() {
        let languageKind = LanguageKind.portuguese
        XCTAssertEqual(languageKind.name, AppStrings.Sections.Language.portuguese)
    }
}

//
//  LanguageProficiencyTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class LanguageProficiencyTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testNameElementary() {
        let proficiency = LanguageProficiency.elementary
        XCTAssertEqual(proficiency.name, AppStrings.Sections.Language.elementary)
    }
    
    func testNameLimited() {
        let proficiency = LanguageProficiency.limited
        XCTAssertEqual(proficiency.name, AppStrings.Sections.Language.limited)
    }
    
    func testNameGeneral() {
        let proficiency = LanguageProficiency.general
        XCTAssertEqual(proficiency.name, AppStrings.Sections.Language.general)
    }
    
    func testNameAdvanced() {
        let proficiency = LanguageProficiency.advanced
        XCTAssertEqual(proficiency.name, AppStrings.Sections.Language.advanced)
    }
    
    func testNameFunctionally() {
        let proficiency = LanguageProficiency.functionally
        XCTAssertEqual(proficiency.name, AppStrings.Sections.Language.functionally)
    }
}

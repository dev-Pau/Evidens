//
//  CaseItemTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class CaseItemTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCaseItemTitle() {
        XCTAssertEqual(CaseItem.general.title, AppStrings.Content.Case.Item.general)
        XCTAssertEqual(CaseItem.teaching.title, AppStrings.Content.Case.Item.teaching)
        XCTAssertEqual(CaseItem.common.title, AppStrings.Content.Case.Item.common)
        XCTAssertEqual(CaseItem.uncommon.title, AppStrings.Content.Case.Item.uncommon)
        XCTAssertEqual(CaseItem.new.title, AppStrings.Content.Case.Item.new)
        XCTAssertEqual(CaseItem.rare.title, AppStrings.Content.Case.Item.rare)
        XCTAssertEqual(CaseItem.diagnostic.title, AppStrings.Content.Case.Item.diagnostic)
        XCTAssertEqual(CaseItem.multidisciplinary.title, AppStrings.Content.Case.Item.multidisciplinary)
        XCTAssertEqual(CaseItem.technology.title, AppStrings.Content.Case.Item.technology)
        XCTAssertEqual(CaseItem.strategies.title, AppStrings.Content.Case.Item.strategies)
    }

    func testAllCaseItemTitles() {
        CaseItem.allCases.forEach { item in
            XCTAssertFalse(item.title.isEmpty, "Title should not be empty for \(item)")
        }
    }
}

//
//  CaseFilterTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class CaseFilterTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCaseFilterTitle() {
        XCTAssertEqual(CaseFilter.latest.title, AppStrings.Content.Case.Category.latest)
        XCTAssertEqual(CaseFilter.featured.title, AppStrings.Search.Topics.featured)
    }

    func testAllCaseFilterTitles() {
        CaseFilter.allCases.forEach { filter in
            XCTAssertFalse(filter.title.isEmpty, "Title should not be empty for \(filter)")
        }
    }
}

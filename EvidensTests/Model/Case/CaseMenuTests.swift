//
//  CaseMenuTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class CaseMenuTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCaseMenuTitle() {
        XCTAssertEqual(CaseMenu.delete.title, AppStrings.Menu.deleteCase)
        XCTAssertEqual(CaseMenu.revision.title, AppStrings.Menu.revisionCase)
        XCTAssertEqual(CaseMenu.solve.title, AppStrings.Menu.solve)
        XCTAssertEqual(CaseMenu.report.title, AppStrings.Menu.reportCase)
    }
    
    func testCaseMenuImage() {
        XCTAssertEqual(CaseMenu.delete.image, UIImage(systemName: AppStrings.Icons.trash, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!)
        XCTAssertEqual(CaseMenu.revision.image, UIImage(systemName: AppStrings.Icons.plus, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!)
        XCTAssertEqual(CaseMenu.solve.image, UIImage(systemName: AppStrings.Icons.heart, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!)
        XCTAssertEqual(CaseMenu.report.image, UIImage(systemName: AppStrings.Icons.flag, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!)
    }
    
    // Additional test cases if needed...
    
    // Test cases for all cases in CaseMenu
    func testAllCaseMenuTitles() {
        CaseMenu.allCases.forEach { menu in
            XCTAssertFalse(menu.title.isEmpty, "Title should not be empty for \(menu)")
        }
    }
}

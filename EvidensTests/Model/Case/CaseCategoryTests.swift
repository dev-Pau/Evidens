//
//  CaseCategoryTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class CaseCategoryTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCaseCategoryTitle() {
        let youCategory = CaseCategory.you
        XCTAssertEqual(youCategory.title, AppStrings.Content.Case.Category.you)
        
        let latestCategory = CaseCategory.latest
        XCTAssertEqual(latestCategory.title, AppStrings.Content.Case.Category.latest)
    }
}

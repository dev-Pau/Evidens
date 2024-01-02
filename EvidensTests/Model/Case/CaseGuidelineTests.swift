//
//  CaseGuidelineTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class CaseGuidelineTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    func testTitle() {
        XCTAssertEqual(CaseGuideline.classify.title, AppStrings.Guidelines.Case.classify)
        XCTAssertEqual(CaseGuideline.form.title, AppStrings.Guidelines.Case.form)
        XCTAssertEqual(CaseGuideline.stage.title, AppStrings.Guidelines.Case.stage)
        XCTAssertEqual(CaseGuideline.submit.title, AppStrings.Guidelines.Case.submit)
    }
    
    func testContent() {
        XCTAssertEqual(CaseGuideline.classify.content, AppStrings.Guidelines.Case.classifyContent)
        XCTAssertEqual(CaseGuideline.form.content, AppStrings.Guidelines.Case.formContent)
        XCTAssertEqual(CaseGuideline.stage.content, AppStrings.Guidelines.Case.stageContent)
        XCTAssertEqual(CaseGuideline.submit.content, AppStrings.Guidelines.Case.submitContent)
    }
    
    func testAllCasesHaveTitles() {
        for guideline in CaseGuideline.allCases {
            XCTAssertFalse(guideline.title.isEmpty, "\(guideline) has an empty title.")
        }
    }
    
    func testAllCasesHaveContent() {
        for guideline in CaseGuideline.allCases {
            XCTAssertFalse(guideline.content.isEmpty, "\(guideline) has empty content.")
        }
    }
}

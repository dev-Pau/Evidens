//
//  PostGuidelineTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 8/1/24.
//

import XCTest
@testable import Evidens

final class PostGuidelineTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testTitle() {
        XCTAssertEqual(PostGuideline.classify.title, AppStrings.Guidelines.Post.classify)
        XCTAssertEqual(PostGuideline.form.title, AppStrings.Guidelines.Post.form)
        XCTAssertEqual(PostGuideline.submit.title, AppStrings.Guidelines.Post.submit)
    }
    
    func testContent() {
        XCTAssertEqual(PostGuideline.classify.content, AppStrings.Guidelines.Post.classifyContent)
        XCTAssertEqual(PostGuideline.form.content, AppStrings.Guidelines.Post.formContent)
        XCTAssertEqual(PostGuideline.submit.content, AppStrings.Guidelines.Post.submitContent)
    }
    
    func testAllCasesHaveTitles() {
        for guideline in PostGuideline.allCases {
            XCTAssertFalse(guideline.title.isEmpty, "\(guideline) has an empty title.")
        }
    }
    
    func testAllCasesHaveContent() {
        for guideline in CaseGuideline.allCases {
            XCTAssertFalse(guideline.content.isEmpty, "\(guideline) has empty content.")
        }
    }
}

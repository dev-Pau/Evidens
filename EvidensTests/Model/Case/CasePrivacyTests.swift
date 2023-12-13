//
//  CasePrivacyTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class CasePrivacyTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCasePrivacyTitle() {
        XCTAssertEqual(CasePrivacy.regular.title, AppStrings.Content.Case.Privacy.regularTitle)
        XCTAssertEqual(CasePrivacy.anonymous.title, AppStrings.Content.Case.Privacy.anonymousTitle)
    }
    
    func testCasePrivacyContent() {
        XCTAssertEqual(CasePrivacy.regular.content, AppStrings.Content.Case.Privacy.regularContent)
        XCTAssertEqual(CasePrivacy.anonymous.content, AppStrings.Content.Case.Privacy.anonymousContent)
    }
    
    func testCasePrivacyImage() {
        XCTAssertEqual(CasePrivacy.regular.image, UIImage(systemName: AppStrings.Icons.fillEuropeGlobe, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!)
        XCTAssertEqual(CasePrivacy.anonymous.image, UIImage(systemName: AppStrings.Icons.eyeGlasses, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!)
    }

    func testAllCasePrivacyTitles() {
        CasePrivacy.allCases.forEach { privacy in
            XCTAssertFalse(privacy.title.isEmpty, "Title should not be empty for \(privacy)")
        }
    }
    
    func testAllCasePrivacyContents() {
        CasePrivacy.allCases.forEach { privacy in
            XCTAssertFalse(privacy.content.isEmpty, "Content should not be empty for \(privacy)")
        }
    }
}

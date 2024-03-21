//
//  ReferenceKindTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 12/12/23.
//

import XCTest
@testable import Evidens

final class ReferenceKindTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testLinkMessage() {
        let referenceKind = ReferenceKind.link
        XCTAssertEqual(referenceKind.message, AppStrings.Reference.linkTitle)
    }
    
    func testLinkImage() {
        let referenceKind = ReferenceKind.link
        let expectedImage = UIImage(systemName: AppStrings.Icons.note, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(K.Colors.primaryColor)
        XCTAssertEqual(referenceKind.image, expectedImage)
    }
    
    func testLinkOptionMenuMessage() {
        let referenceKind = ReferenceKind.link
        XCTAssertEqual(referenceKind.optionMenuMessage, AppStrings.Reference.linkContent)
    }
    
    func testCitationMessage() {
        let referenceKind = ReferenceKind.citation
        XCTAssertEqual(referenceKind.message, AppStrings.Reference.citationTitle)
    }
    
    func testCitationImage() {
        let referenceKind = ReferenceKind.citation
        let expectedImage = UIImage(systemName: AppStrings.Icons.note, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(K.Colors.primaryColor)
        XCTAssertEqual(referenceKind.image, expectedImage)
    }
    
    func testCitationOptionMenuMessage() {
        let referenceKind = ReferenceKind.citation
        XCTAssertEqual(referenceKind.optionMenuMessage, AppStrings.Reference.citationContent)
    }
}

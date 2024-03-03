//
//  LegalKindTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 12/12/23.
//

import XCTest
@testable import Evidens

final class LegalKindTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testTermsTitle() {
        let legalKind = LegalKind.terms
        XCTAssertEqual(legalKind.title, AppStrings.Legal.terms)
    }
    
    func testPrivacyTitle() {
        let legalKind = LegalKind.privacy
        XCTAssertEqual(legalKind.title, AppStrings.Legal.privacy)
    }
}

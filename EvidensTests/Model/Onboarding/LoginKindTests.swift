//
//  LoginKindTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 12/12/23.
//

import XCTest
@testable import Evidens

final class LoginKindTests: XCTestCase {
    
    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        
    }

    func testCountValues() {
        let sut = LoginKind.allCases.count
        XCTAssertEqual(sut, 2, "Data should match")
    }
    
    func testTitleValues() {
        var sut = LoginKind.google
        
        XCTAssertEqual(sut.title, AppStrings.Opening.googleSignIn, "Data should match")
        
        sut = LoginKind.apple
        
        XCTAssertEqual(sut.title, AppStrings.Opening.appleSignIn, "Data should match")
    }
}

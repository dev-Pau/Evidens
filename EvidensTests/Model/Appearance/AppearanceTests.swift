//
//  AppearanceTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class AppearanceTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testTitleDark() {
        let appearance = Appearance.dark
        XCTAssertEqual(appearance.title, AppStrings.Appearance.dark)
    }
    
    func testTitleSystem() {
        let appearance = Appearance.system
        XCTAssertEqual(appearance.title, AppStrings.Appearance.system)
    }
    
    func testTitleLight() {
        let appearance = Appearance.light
        XCTAssertEqual(appearance.title, AppStrings.Appearance.light)
    }
}

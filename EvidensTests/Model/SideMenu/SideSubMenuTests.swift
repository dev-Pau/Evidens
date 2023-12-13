//
//  SideSubMenuTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 12/12/23.
//

import XCTest
@testable import Evidens

final class SideSubMenuTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSettingsTitle() {
        let sideSubMenu = SideSubMenu.settings
        XCTAssertEqual(sideSubMenu.title, AppStrings.SideMenu.settingsAndLegal)
    }
    
    func testSettingsKind() {
        let sideSubMenu = SideSubMenu.settings
        let expectedKind: [SideSubMenuKind] = [.settings, .legal]
        XCTAssertEqual(sideSubMenu.kind, expectedKind)
    }
    
    func testHelpTitle() {
        let sideSubMenu = SideSubMenu.help
        XCTAssertEqual(sideSubMenu.title, AppStrings.SideMenu.helpAndSupport)
    }
    
    func testHelpKind() {
        let sideSubMenu = SideSubMenu.help
        let expectedKind: [SideSubMenuKind] = [.app, .contact]
        XCTAssertEqual(sideSubMenu.kind, expectedKind)
    }
}

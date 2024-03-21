//
//  SideSubMenuKindTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 12/12/23.
//

import XCTest
@testable import Evidens

final class SideSubMenuKindTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSettingsTitle() {
        let subMenuKind = SideSubMenuKind.settings
        XCTAssertEqual(subMenuKind.title, AppStrings.SideMenu.settings)
    }
    
    func testSettingsImage() {
        let subMenuKind = SideSubMenuKind.settings
        let expectedImage = UIImage(systemName: AppStrings.Icons.gear, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal)
        XCTAssertEqual(subMenuKind.image, expectedImage)
    }
    
    func testLegalTitle() {
        let subMenuKind = SideSubMenuKind.legal
        XCTAssertEqual(subMenuKind.title, AppStrings.SideMenu.legal)
    }
    
    func testLegalImage() {
        let subMenuKind = SideSubMenuKind.legal
        let expectedImage = UIImage(systemName: AppStrings.Icons.scalemass, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal)
        XCTAssertEqual(subMenuKind.image, expectedImage)
    }
    
    func testAppTitle() {
        let subMenuKind = SideSubMenuKind.app
        XCTAssertEqual(subMenuKind.title, AppStrings.SideMenu.about)
    }
    
    func testAppImage() {
        let subMenuKind = SideSubMenuKind.app
        let expectedImage = UIImage(named: AppStrings.Assets.blackLogo)?.withTintColor(K.Colors.primaryColor)
        XCTAssertEqual(subMenuKind.image, expectedImage)
    }
    
    func testContactTitle() {
        let subMenuKind = SideSubMenuKind.contact
        XCTAssertEqual(subMenuKind.title, AppStrings.SideMenu.contact)
    }
    
    func testContactImage() {
        let subMenuKind = SideSubMenuKind.contact
        let expectedImage = UIImage(systemName: AppStrings.Icons.circleQuestion, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal)
        XCTAssertEqual(subMenuKind.image, expectedImage)
    }
}

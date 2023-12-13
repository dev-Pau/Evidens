//
//  SubSettingKindTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 12/12/23.
//

import XCTest
@testable import Evidens

final class SubSettingKindTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAccountTitle() {
        let subSettingKind = SubSettingKind.account
        XCTAssertEqual(subSettingKind.title, AppStrings.Settings.accountInfoTitle)
    }
    
    func testAccountContent() {
        let subSettingKind = SubSettingKind.account
        XCTAssertEqual(subSettingKind.content, AppStrings.Settings.accountInfoContent)
    }
    
    func testAccountImage() {
        let subSettingKind = SubSettingKind.account
        let expectedImage = UIImage(systemName: AppStrings.Icons.person, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        XCTAssertEqual(subSettingKind.image, expectedImage)
    }
    
    func testPasswordTitle() {
        let subSettingKind = SubSettingKind.password
        XCTAssertEqual(subSettingKind.title, AppStrings.Settings.accountPasswordTitle)
    }
    
    func testPasswordContent() {
        let subSettingKind = SubSettingKind.password
        XCTAssertEqual(subSettingKind.content, AppStrings.Settings.accountPasswordContent)
    }
    
    func testPasswordImage() {
        let subSettingKind = SubSettingKind.password
        let expectedImage = UIImage(systemName: AppStrings.Icons.key, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        XCTAssertEqual(subSettingKind.image, expectedImage)
    }
    
    func testDeactivateTitle() {
        let subSettingKind = SubSettingKind.deactivate
        XCTAssertEqual(subSettingKind.title, AppStrings.Settings.accountDeactivateTitle)
    }
    
    func testDeactivateContent() {
        let subSettingKind = SubSettingKind.deactivate
        XCTAssertEqual(subSettingKind.content, AppStrings.Settings.accountDeactivateContent)
    }
    
    func testDeactivateImage() {
        let subSettingKind = SubSettingKind.deactivate
        let expectedImage = UIImage(named: AppStrings.Assets.brokenHeart)?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        XCTAssertEqual(subSettingKind.image, expectedImage)
    }
}

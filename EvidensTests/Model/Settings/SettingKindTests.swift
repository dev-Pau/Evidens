//
//  SettingKindTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 12/12/23.
//

import XCTest
@testable import Evidens

final class SettingKindTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAccountTitle() {
        let settingKind = SettingKind.account
        XCTAssertEqual(settingKind.title, AppStrings.Settings.accountTitle)
    }
    
    func testAccountContent() {
        let settingKind = SettingKind.account
        XCTAssertEqual(settingKind.content, AppStrings.Settings.accountContent)
    }
    
    func testAccountImage() {
        let settingKind = SettingKind.account
        let expectedImage = UIImage(systemName: AppStrings.Icons.person, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(K.Colors.primaryGray)
        XCTAssertEqual(settingKind.image, expectedImage)
    }
    
    func testNotificationsTitle() {
        let settingKind = SettingKind.notifications
        XCTAssertEqual(settingKind.title, AppStrings.Settings.notificationsTitle)
    }
    
    func testNotificationsContent() {
        let settingKind = SettingKind.notifications
        XCTAssertEqual(settingKind.content, AppStrings.Settings.notificationsContent)
    }
    
    func testNotificationsImage() {
        let settingKind = SettingKind.notifications
        let expectedImage = UIImage(systemName: AppStrings.Icons.bell, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(K.Colors.primaryGray)
        XCTAssertEqual(settingKind.image, expectedImage)
    }
    
    func testAccountSubSettings() {
        let settingKind = SettingKind.account
        let expectedSubSettings: [SubSettingKind] = [.account, .password, .deactivate]
        XCTAssertEqual(settingKind.subSetting, expectedSubSettings)
    }
    
    func testNotificationsSubSettings() {
        let settingKind = SettingKind.notifications
        let expectedSubSettings: [SubSettingKind] = []
        XCTAssertEqual(settingKind.subSetting, expectedSubSettings)
    }
}

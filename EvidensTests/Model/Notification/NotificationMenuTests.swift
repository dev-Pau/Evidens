//
//  NotificationMenuTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class NotificationMenuTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testNotificationMenuContentDelete() {
        XCTAssertEqual(NotificationMenu.delete.content, AppStrings.Alerts.Title.deleteNotification)
    }
    
    func testNotificationMenuImageDelete() {
        XCTAssertEqual(NotificationMenu.delete.image, UIImage(systemName: AppStrings.Icons.trash)!)
    }
}

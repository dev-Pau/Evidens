//
//  NotificationGroupTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class NotificationGroupTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTitle() {
        XCTAssertEqual(NotificationGroup.activity.title, AppStrings.Notifications.Settings.activity)
        XCTAssertEqual(NotificationGroup.network.title, AppStrings.Notifications.Settings.network)
    }
    
    func testTopic() {
        XCTAssertEqual(NotificationGroup.activity.topic, [.replies, .likes, .followers, .messages])
        XCTAssertEqual(NotificationGroup.network.topic, [.cases])
    }
}

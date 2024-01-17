//
//  NotificationTopicTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class NotificationTopicTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testTitle() {
        XCTAssertEqual(NotificationTopic.replies.title, AppStrings.Notifications.Settings.repliesTitle)
        XCTAssertEqual(NotificationTopic.likes.title, AppStrings.Notifications.Settings.likesTitle)
        XCTAssertEqual(NotificationTopic.connections.title, AppStrings.Notifications.Settings.connectionsTitle)
        XCTAssertEqual(NotificationTopic.cases.title, AppStrings.Notifications.Settings.trackCases)
    }
    
    func testContent() {
        XCTAssertEqual(NotificationTopic.replies.content, AppStrings.Notifications.Settings.repliesContent)
        XCTAssertEqual(NotificationTopic.likes.content, AppStrings.Notifications.Settings.likesContent)
        XCTAssertEqual(NotificationTopic.connections.content, "")
        XCTAssertEqual(NotificationTopic.cases.content, AppStrings.Notifications.Settings.trackCasesContent)
    }
    
    func testTarget() {
        XCTAssertEqual(NotificationTopic.replies.target, AppStrings.Notifications.Settings.repliesTarget)
        XCTAssertEqual(NotificationTopic.likes.target, AppStrings.Notifications.Settings.likesTarget)
        XCTAssertEqual(NotificationTopic.connections.target, "")
        XCTAssertEqual(NotificationTopic.cases.target, "")
    }
}

//
//  NotificationViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 2/1/24.
//

import XCTest
@testable import Evidens

final class NotificationViewModelTests: XCTestCase {
    
    var sut: NotificationViewModel!
    
    override func setUpWithError() throws {
        
        
        let data = ["id": "notificationId",
                    "uid": "userUid",
                    "kind": NotificationKind.likePost.rawValue,
                    "timestamp": Date.now,
                    "contentId": "contentId",
                    "path": ["path1", "path2"]
        ] as [String : Any]
        
        var notification = Notification(dictionary: data)
        
        notification.name = "John Doe"
        notification.set(image: "https://example.com/image.jpg")
        notification.set(content: "Post Content")
        notification.set(isRead: true)
        notification.set(likes: 2)
        
        sut = NotificationViewModel(notification: notification)
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    
    func testTime() {
        XCTAssertFalse(sut.time.isEmpty)
    }
    
    func testIsRead() {
        XCTAssertTrue(sut.isRead)
    }
    
    func testName() {
        XCTAssertEqual(sut.name, "John Doe")
    }
    
    func testImage() {
        XCTAssertNotNil(sut.image())
        XCTAssertEqual(sut.image(), URL(string: "https://example.com/image.jpg"))
    }
    
    func testConnectText() {
        XCTAssertEqual(sut.connectText, AppStrings.Title.connect)
    }
    
    func testKindSummary() {

        XCTAssertEqual(sut.summary, "and others ")
    }
    
    func testContent() {
        XCTAssertEqual(sut.content, "\"Post Content\". ")
    }
}

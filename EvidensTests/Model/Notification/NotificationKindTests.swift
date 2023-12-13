//
//  NotificationKindTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class NotificationKindTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testNotificationKindMessageLikePost() {
        XCTAssertEqual(NotificationKind.likePost.message, AppStrings.Notifications.Display.likePost)
    }
    
    func testNotificationKindMessageLikeCase() {
        XCTAssertEqual(NotificationKind.likeCase.message, AppStrings.Notifications.Display.likeCase)
    }
    
    func testNotificationKindMessageConnectionRequest() {
        XCTAssertEqual(NotificationKind.connectionRequest.message, AppStrings.Notifications.Display.connectionRequest)
    }
    
    func testNotificationKindMessageReplyPost() {
        XCTAssertEqual(NotificationKind.replyPost.message, AppStrings.Notifications.Display.replyPost)
    }
    
    func testNotificationKindMessageReplyCase() {
        XCTAssertEqual(NotificationKind.replyCase.message, AppStrings.Notifications.Display.replyCase)
    }
    
    func testNotificationKindMessageReplyPostComment() {
        XCTAssertEqual(NotificationKind.replyPostComment.message, AppStrings.Notifications.Display.replyComment)
    }
    
    func testNotificationKindMessageReplyCaseComment() {
        XCTAssertEqual(NotificationKind.replyCaseComment.message, AppStrings.Notifications.Display.replyComment)
    }
    
    func testNotificationKindMessageLikePostReply() {
        XCTAssertEqual(NotificationKind.likePostReply.message, AppStrings.Notifications.Display.likeReply)
    }
    
    func testNotificationKindMessageLikeCaseReply() {
        XCTAssertEqual(NotificationKind.likeCaseReply.message, AppStrings.Notifications.Display.likeReply)
    }
    
    func testNotificationKindMessageConnectionAccept() {
        XCTAssertEqual(NotificationKind.connectionAccept.message, AppStrings.Notifications.Display.connectionAccept)
    }
}

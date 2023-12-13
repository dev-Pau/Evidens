//
//  ConversationTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class ConversationTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testInitWithFullData() {
        let id = "123"
        let name = "John Doe"
        let image = "profile_image.jpg"
        let userId = "456"
        let unreadMessages = 3
        let isPinned = true
        let date = Date()
        let latestMessage = Message(text: "Hello", sentDate: Date(), messageId: "789", isRead: false, senderId: "456", kind: .text, phase: .unread)
        
        let conversation = Conversation(id: id, name: name, image: image, userId: userId, unreadMessages: unreadMessages, isPinned: isPinned, date: date, latestMessage: latestMessage)
        
        XCTAssertEqual(conversation.id, id)
        XCTAssertEqual(conversation.name, name)
        XCTAssertEqual(conversation.image, image)
        XCTAssertEqual(conversation.userId, userId)
        XCTAssertEqual(conversation.unreadMessages, unreadMessages)
        XCTAssertEqual(conversation.isPinned, isPinned)
        XCTAssertEqual(conversation.date, date)
        XCTAssertEqual(conversation.latestMessage?.messageId ?? "", latestMessage.messageId)
    }
    
    func testInitWithEmptyData() {
        let name = "John Doe"
        let userId = "456"
        let ownerId = "789"
        
        let conversation = Conversation(name: name, userId: userId, ownerId: ownerId)
        
        XCTAssertNotNil(conversation.id)
        XCTAssertEqual(conversation.name, name)
        XCTAssertNil(conversation.image)
        XCTAssertNil(conversation.unreadMessages)
        XCTAssertFalse(conversation.isPinned)
        XCTAssertNil(conversation.date)
        XCTAssertNil(conversation.latestMessage)
    }
    
    func testInitWithPartialData() {
        let id = "123"
        let name = "John Doe"
        let userId = "456"
        let date = Date()
        let image = "profile_image.jpg"
        
        let conversation = Conversation(id: id, userId: userId, name: name, date: date, image: image)
        
        XCTAssertEqual(conversation.id, id)
        XCTAssertEqual(conversation.name, name)
        XCTAssertEqual(conversation.userId, userId)
        XCTAssertEqual(conversation.date, date)
        XCTAssertEqual(conversation.image, image)
        XCTAssertNil(conversation.unreadMessages)
        XCTAssertFalse(conversation.isPinned)
        XCTAssertNil(conversation.latestMessage)
    }
}

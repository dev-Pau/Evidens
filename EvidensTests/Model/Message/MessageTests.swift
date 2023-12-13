//
//  MessageTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class MessageTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testInitWithParameters() {
        
        let date = Date()
        let messageId = "123"
        let senderId = "456"
        let message = Message(text: "Hello", sentDate: date, messageId: messageId, isRead: false, senderId: senderId, kind: .text, phase: .unread)
        
        XCTAssertEqual(message.text, "Hello")
        XCTAssertEqual(message.sentDate, date)
        XCTAssertEqual(message.messageId, messageId)
        XCTAssertFalse(message.isRead)
        XCTAssertEqual(message.senderId, senderId)
        XCTAssertNil(message.image)
        XCTAssertEqual(message.kind, .text)
        XCTAssertEqual(message.phase, .unread)
    }
    
    func testInitWithDictionary() {
        let dictionary: [String: Any] = [
            "text": "Hello",
            "date": 123456789.0,
            "senderId": "456",
            "kind": 1,
        ]
        
        let messageId = "123"
        let message = Message(dictionary: dictionary, messageId: messageId)
        
        XCTAssertEqual(message.text, "Hello")
        XCTAssertEqual(message.sentDate, Date(timeIntervalSince1970: 123456789.0))
        XCTAssertEqual(message.messageId, messageId)
        XCTAssertFalse(message.isRead)
        XCTAssertEqual(message.senderId, "456")
        XCTAssertEqual(message.kind, .text)
        XCTAssertEqual(message.phase, .unread)
    }
    
    func testUpdatePhase() {
        var message = Message(text: "Hello", sentDate: Date(), messageId: "123", isRead: false, senderId: "456", kind: .text, phase: .unread)
        message.updatePhase(.read)
        XCTAssertEqual(message.phase, .read)
    }
    
    func testMarkAsRead() {
        var message = Message(text: "Hello", sentDate: Date(), messageId: "123", isRead: false, senderId: "456", kind: .text, phase: .unread)
        message.markAsRead()
        XCTAssertTrue(message.isRead)
    }
    
    func testUpdateImage() {
        var message = Message(text: "Hello", sentDate: Date(), messageId: "123", isRead: false, senderId: "456", kind: .text, phase: .unread)
        message.updateImage("imageURL")
        XCTAssertEqual(message.image, "imageURL")
    }
}

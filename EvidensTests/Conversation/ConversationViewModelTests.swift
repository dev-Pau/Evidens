//
//  ConversationViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 15/9/23.
//

import XCTest
@testable import Evidens

final class ConversationViewModelTests: XCTestCase {
    
    var sut: ConversationViewModel!

    override func setUpWithError() throws {
       let message = Message(text: "Hello", sentDate: Date(), messageId: "messageID", isRead: false, senderId: "senderId", kind: .text, phase: .sent)
        
        let conversation = Conversation(id: "conversationID", name: "John", image: nil, userId: "userId", unreadMessages: 2, isPinned: true, date: Date(), latestMessage: message)
        
        sut = ConversationViewModel(conversation: conversation)
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testFirstName() {
        XCTAssertEqual(sut.name, "John")
    }
    
    func testUnreadMessages() {
        XCTAssertEqual(sut.unreadMessages, 2)
    }
    
    func testIsPinned() {
        XCTAssertTrue(sut.isPinned)
    }
    
    func testColor() {
        XCTAssertEqual(sut.messageColor, primaryColor)
    }
}

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

    func testConversationViewModel_WhenGettingFirstName_ShouldBeEqual() {
        XCTAssertEqual(sut.name, "John")
    }
    
    func testConversationViewModel_WhenGettingUnreadMessages_ShouldBeEqual() {
        XCTAssertEqual(sut.unreadMessages, 2)
    }
    
    func testConversationViewModel_WhenGettingIsPinned_ShouldReturnTrue() {
        XCTAssertTrue(sut.isPinned)
    }
    
    func testConversationViewModel_ColorForIsReadMessage_ShouldReturnPrimary() {
        XCTAssertEqual(sut.messageColor, primaryColor)
    }
}

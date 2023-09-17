//
//  MessageViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 15/9/23.
//

import XCTest
@testable import Evidens

final class MessageViewModelTests: XCTestCase {
    
    var sut: MessageViewModel!

    override func setUpWithError() throws {
        let message = Message(text: "Hello", sentDate: Date(), messageId: "messageID", isRead: false, senderId: "senderId", kind: .text, phase: .sent)
        sut = MessageViewModel(message: message)
    }

    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testMessageViewModel_WhenUserIdMatchesSenderId_ReturnsTrue() {
            UserDefaults.standard.setValue("senderId", forKey: "uid")
            XCTAssertTrue(sut.isSender)
        }

    func testMessageViewModel_WhenUserIdDoesNotMatchSenderId_ReturnsFalse() {
        UserDefaults.standard.setValue("otherUserId", forKey: "uid")
        XCTAssertFalse(sut.isSender)
    }
    
    func testMessageViewModel_ReturnsMessageKind_ShouldReturnSameKind() {
        XCTAssertEqual(sut.kind, .text)
    }
    
    func testMessageViewModel_ReturnsMessageText_ShouldReturnSameText() {
        XCTAssertEqual(sut.text, "Hello")
    }
    
    func testMessageViewModel_WhenNotContainsOnlyEmoji_ShouldReturnFalse() {
        let message = Message(text: "Hello", sentDate: Date(), messageId: "messageID", isRead: false, senderId: "senderId", kind: .text, phase: .sent)
        XCTAssertFalse(sut.emoji)
        
    }
    
    func testMessageViewModel_WhenContainsOnlyEmoji_ShouldReturnTrue() {
        let message = Message(text: "😀", sentDate: Date(), messageId: "messageID", isRead: false, senderId: "senderId", kind: .text, phase: .sent)
        let anotherMessage = Message(text: "😀😎", sentDate: Date(), messageId: "messageID", isRead: false, senderId: "senderId", kind: .text, phase: .sent)

        let viewModel = MessageViewModel(message: message)
        let anotherViewModel = MessageViewModel(message: anotherMessage)
        
        XCTAssertTrue(viewModel.emoji)
        XCTAssertTrue(anotherViewModel.emoji)
    }
}

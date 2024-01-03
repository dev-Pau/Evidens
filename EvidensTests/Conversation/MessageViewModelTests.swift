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
    
    func testIsSenderValid() {
            UserDefaults.standard.setValue("senderId", forKey: "uid")
            XCTAssertTrue(sut.isSender)
        }

    func testtestIsSenderInvalid() {
        UserDefaults.standard.setValue("otherUserId", forKey: "uid")
        XCTAssertFalse(sut.isSender)
    }
    
    func testKind() {
        XCTAssertEqual(sut.kind, .text)
    }
    
    func testText() {
        XCTAssertEqual(sut.text, "Hello")
    }
    
    func testNoEmoji() {
        XCTAssertFalse(sut.emoji)
        
    }
    
    func testOnlyEmoji() {
        let message = Message(text: "😀", sentDate: Date(), messageId: "messageID", isRead: false, senderId: "senderId", kind: .text, phase: .sent)
        let anotherMessage = Message(text: "😀😎", sentDate: Date(), messageId: "messageID", isRead: false, senderId: "senderId", kind: .text, phase: .sent)

        let viewModel = MessageViewModel(message: message)
        let anotherViewModel = MessageViewModel(message: anotherMessage)
        
        XCTAssertTrue(viewModel.emoji)
        XCTAssertTrue(anotherViewModel.emoji)
    }
}

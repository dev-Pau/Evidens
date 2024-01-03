//
//  ConversationNotificationTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 18/9/23.
//

import XCTest
import CoreData
@testable import Evidens

final class ConversationDataTests: XCTestCase {

    var sut: DataService!
    
    var message: Message!
    var conversation: Conversation!
    
    let date = Date.now
    
    override func setUpWithError() throws {
        sut = DataService.shared
        sut.mockManagedObjectContext = mockPersistantContainer.viewContext
        
        message = Message(text: "This is a message", sentDate: Date.now, messageId: "messageId", isRead: false, senderId: "senderId", kind: .text, phase: .sent)
        
        conversation = Conversation(id: "conversationId", name: "conversationName", image: nil, userId: "userId", unreadMessages: 4, isPinned: true, date: date, latestMessage: message)
    }

    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testDataService_SaveConversationWithLatestMessage_ShouldSaveConversation() {
        
        sut.save(conversation: conversation, latestMessage: message)
        
        let conversations = sut.getConversations(for: [conversation.id!])
        let messages = sut.getMessages(for: conversation)
        
        XCTAssertEqual(conversations.count, 1)
        XCTAssertEqual(messages.count, 1)
    }
    
    func testDataService_SaveMessageToConversation_ShouldSaveMessage() {
        sut.save(conversation: conversation, latestMessage: message)
        
        let newMessage = Message(text: "This is another message message", sentDate: Date.now, messageId: "anotherMessageId", isRead: false, senderId: "anotherSenderId", kind: .text, phase: .sent)
        
        sut.save(message: newMessage, to: conversation)
        
        let messages = sut.getMessages(for: conversation)
        
        XCTAssertEqual(messages.count, 2)
    }
    
    func testDataService_SaveMessageToConversationWithId_ShouldSaveMessage() {
        sut.save(conversation: conversation, latestMessage: message)
        
        let newMessage = Message(text: "This is another message message", sentDate: Date.now, messageId: "anotherMessageId", isRead: false, senderId: "anotherSenderId", kind: .text, phase: .sent)
        
        sut.save(message: newMessage, to: conversation.id!)
        
        let messages = sut.getMessages(for: conversation)
        
        XCTAssertEqual(messages.count, 2)
    }
    
    func testDataService_WhenNoConversationsAreSaved_ShouldReturnEmpty() {
        let conversations = sut.getConversations()
        XCTAssert(conversations.isEmpty)
    }
    
    func testDataService_WhenConversationsAreSaved_ShouldReturnSavedConversations() {
        sut.save(conversation: conversation, latestMessage: message)
        let conversations = sut.getConversations()
        XCTAssertEqual(conversations.count, 1)
    }
    
    func testDataService_WhenGettingExistingConversation_ConversationShouldBeTheSame() {
        sut.save(conversation: conversation, latestMessage: message)
        
        let fetchedConversation = sut.getConversation(with: conversation.id!)

        XCTAssertEqual(conversation, fetchedConversation)
    }
    
    func testDataService_WhenGettingFakeConversation_ConversationShouldBeNil() {
        let fetchedConversation = sut.getConversation(with: conversation.id!)

        XCTAssertNil(fetchedConversation)
    }
    
    func testDataService_getUnreadMessagesForUnreadConversation_ShouldReturnUnreadConversations() {
        sut.save(conversation: conversation, latestMessage: message)
        
        let unreadMessages = sut.getUnreadConversations()
        
        XCTAssertEqual(unreadMessages, 1)
    }
    
    func testDataService_getUnreadMessagesForEmptyConversations_ShouldReturnZero() {

        let unreadMessages = sut.getUnreadConversations()
        
        XCTAssertEqual(unreadMessages, 0)
    }
    
    func testDataService_getConversationsAroundMessage_ShouldReturnMessagesCount() {
        sut.save(conversation: conversation, latestMessage: message)
        
        let newMessage = Message(text: "This is another message", sentDate: Date.now, messageId: "anotherMessageId", isRead: false, senderId: "anotherSenderId", kind: .text, phase: .sent)
        
        let newerMessage = Message(text: "This is newer message", sentDate: Date.now, messageId: "anotherNewerMessage", isRead: false, senderId: "anotherSenderId", kind: .text, phase: .sent)
        
        sut.save(message: newMessage, to: conversation)
        sut.save(message: newerMessage, to: conversation)
        
        let messages = sut.getMessages(for: conversation, around: message)
        
        XCTAssertEqual(messages.count, 3)
    }
    
    func testDataService_getMessagesFromDate_ShouldReturnMessagesCount() {
        sut.save(conversation: conversation, latestMessage: message)
        
        let newMessage = Message(text: "This is another message", sentDate: Calendar.current.date(byAdding: .second, value: -3600, to: Date.now)!, messageId: "anotherMessageId", isRead: false, senderId: "anotherSenderId", kind: .text, phase: .sent)
        
        let olderMessages = Message(text: "This is newer message", sentDate: Calendar.current.date(byAdding: .second, value: -7200, to: Date.now)!, messageId: "anotherNewerMessage", isRead: false, senderId: "anotherSenderId", kind: .text, phase: .sent)
        
        sut.save(message: newMessage, to: conversation)
        sut.save(message: olderMessages, to: conversation)
        
        let messages = sut.getMoreMessages(for: conversation, from: Date.now)
        
        XCTAssertEqual(messages.count, 3)
    }
    
    func testDataService_getMessagesWithText_ShouldReturnMessages() {
        sut.save(conversation: conversation, latestMessage: message)
        
        let newMessage = Message(text: "This is another message", sentDate: Calendar.current.date(byAdding: .second, value: -3600, to: Date.now)!, messageId: "anotherMessageId", isRead: false, senderId: "anotherSenderId", kind: .text, phase: .sent)
        
        let olderMessages = Message(text: "This is an older message", sentDate: Calendar.current.date(byAdding: .second, value: -7200, to: Date.now)!, messageId: "anotherOlderMessage", isRead: false, senderId: "anotherSenderId", kind: .text, phase: .sent)
        
        sut.save(message: newMessage, to: conversation)
        sut.save(message: olderMessages, to: conversation)
        
        let messages = sut.getMessages(for: "older", withLimit: 10, from: Date.now)
        
        XCTAssertEqual(messages.count, 1)
        XCTAssertEqual(messages.first?.text, "This is an older message")
    }
    
    func testDataService_getMessagesWithText_ShouldReturnNoMessages() {
        sut.save(conversation: conversation, latestMessage: message)
        
        let newMessage = Message(text: "This is another message", sentDate: Calendar.current.date(byAdding: .second, value: -3600, to: Date.now)!, messageId: "anotherMessageId", isRead: false, senderId: "anotherSenderId", kind: .text, phase: .sent)
        
        let olderMessages = Message(text: "This is an older message", sentDate: Calendar.current.date(byAdding: .second, value: -7200, to: Date.now)!, messageId: "anotherOlderMessage", isRead: false, senderId: "anotherSenderId", kind: .text, phase: .sent)
        
        sut.save(message: newMessage, to: conversation)
        sut.save(message: olderMessages, to: conversation)
        
        let messages = sut.getMessages(for: "swift", withLimit: 10, from: Date.now)
        
        XCTAssertEqual(messages.count, 0)
    }
    
    func testDataService_ConversationExistsForExistingConversation_ShouldReturnTrue() {
        sut.save(conversation: conversation, latestMessage: message)
        sut.conversationExists(for: conversation.userId) { [weak self] exists in
            guard let _ = self else { return }
            XCTAssertEqual(exists, true)
        }
    }
    
    func testDataService_ConversationExistsForNonExistingConversation_ShouldReturnFalse() {
        sut.conversationExists(for: conversation.id!) { [weak self] exists in
            guard let _ = self else { return }
            XCTAssertEqual(exists, false)
        }
    }
    
    func testDataService_MessageExistsForExistingMessage_ShouldReturnTrue() {
        sut.save(conversation: conversation, latestMessage: message)
        let exists = sut.messageExists(for: message.messageId)
        XCTAssertEqual(exists, true)
    }
    
    
    func testDataService_MessageNoExistsForNonExistingMessage_ShouldReturnFalse() {
        let exists = sut.messageExists(for: message.messageId)
        XCTAssertEqual(exists, false)
    }

    lazy var mockPersistantContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in
            // Check if the data store is in memory
            precondition( description.type == NSInMemoryStoreType )
            
            // Check if creating container wrong
            if let error = error {
                fatalError("Create an in-mem coordinator failed \(error)")
            }
        }
        return container
    }()
}

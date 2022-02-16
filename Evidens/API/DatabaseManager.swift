//
//  DatabaseManager.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 9/12/21.
//

import UIKit
import FirebaseDatabase
import RealmSwift

final class DatabaseManager {
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
}

//MARK: - Account Management

extension DatabaseManager {
    
    /// Inserts new user to database
    public func insertUser(with user: ChatUser) {
        //Create user entry based on UID
        database.child(user.uid).setValue(["firstName": user.firstName,
                                           "lastName": user.lastName,
                                           "emailAddress": user.emailAddress])
        
        self.database.child("users").observeSingleEvent(of: .value) { snapshot in
            if var userCollection = snapshot.value as? [[String: String]] {
                //append to user dictionary
                let newUser = ["name": user.firstName + " " + user.lastName,
                               "emailAddress": user.emailAddress,
                               "uid": user.uid
                              ]
                userCollection.append(newUser)
                
                self.database.child("users").setValue(userCollection) { error, _ in
                    if let error = error { return }
                }
                
                //completion(true)
                
            } else {
                //create the array - only the first user that gets created
                let newCollection: [[String: String]] = [["name": user.firstName + " " + user.lastName,
                                                          "emailAddress": user.emailAddress,
                                                          "uid": user.uid
                                                         ]]
                self.database.child("users").setValue(newCollection) { error, _ in
                    if let error = error { return }
                }
                
                //completion(true)
            }
        }
    }
    
    public func getAllUsers(completion: @escaping(Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        }
    }
    
    public enum DatabaseError: Error {
        case failedToFetch
    }
    
    
}

//MARK: - Sending messages & Conversations
extension DatabaseManager {
    
    /// Creates a new conversation with target user uid and first message sent
    public func createNewConversation(withUid otherUserUid: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
        guard let currentUid = UserDefaults.standard.value(forKey: "uid") else { return }
        print("uid \(currentUid)")
        
        let ref = database.child("\(currentUid)")
        
        ref.observeSingleEvent(of: .value) { snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                return
            }
            
            print("user node is \(userNode)")
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationId = "conversation_\(firstMessage.messageId)"
            
            let newConversationData: [String: Any] = ["id": conversationId,
                                                      "other_user_uid": otherUserUid,
                                                      "latest_message": ["date": dateString,
                                                                         "message": message,
                                                                         "is_read": false
                                                                        ]
            ]
            
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                //Conversation array exists for current user, append
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(conversationID: conversationId,
                                                    firstMessage: firstMessage,
                                                    completion: completion)
                })
            } else {

                //Conversation array does not exist, create it
                userNode["conversations"] = [newConversationData]
                
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(conversationID: conversationId,
                                                    firstMessage: firstMessage,
                                                    completion: completion)
                })
            }
        }
    }
    
    private func finishCreatingConversation(conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        var message = ""
        
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let currentUserUid = UserDefaults.standard.value(forKey: "uid") else {
            completion(false)
            return
        }
        
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_uid": currentUserUid,
            "is_read": false
        ]
        
        let value : [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        print("adding convo: \(conversationID)")
        
        database.child("\(conversationID)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
                                                     }
    
    /// Fetches and returns all conversations for the user with passed in uid
    public func getAllConversations(forUid uid: String, completion: @escaping(Result<String, Error>) -> Void) {
        
    }
    
    /// Get all messages for a given conversation
    public func getAllMessagesForConversation(with id: String, completion: @escaping(Result<String, Error>) -> Void) {
        
    }
    
    /// Sends a message with target conversation and message
    //public func sendMessage(to conversation: String, message: Message, completion: @escaping (Bool) -> Void) {
        
    //}


//Move to models folder
struct ChatUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    let uid: String
    //let profilePictureUrl: URL
}

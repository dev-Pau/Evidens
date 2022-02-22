//
//  DatabaseManager.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 9/12/21.
//

import UIKit
import FirebaseDatabase
import RealmSwift
import MessageKit

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
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        })
    }
    
    
    public enum DatabaseError: Error {
        case failedToFetch
    }
}


//MARK: - Sending messages & Conversations
extension DatabaseManager {
    
    
    
    /// Creates a new conversation with target user uid and first message sent
    public func createNewConversation(withUid otherUserUid: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
        guard let currentUid = UserDefaults.standard.value(forKey: "uid"),
              let currentName = UserDefaults.standard.value(forKey: "name") else { return }

        let ref = database.child("\(currentUid)")
        
        ref.observeSingleEvent(of: .value) { [weak self] snapshot in
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
            
            let newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_uid": otherUserUid,
                "name": name,
                "latest_message": ["date": dateString,
                                   "message": message,
                                   "is_read": false
                ]
            ]
            
            let recipientNewConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_uid": currentUid,
                "name": currentName,
                "latest_message": ["date": dateString,
                                   "message": message,
                                   "is_read": false
                ]
            ]
            
            //Update recipient conversation entry
            self?.database.child("\(otherUserUid)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if var conversations = snapshot.value as? [[String: Any]] {
                    //Append
                    conversations.append(recipientNewConversationData)
                    self?.database.child("\(otherUserUid)/conversations").setValue(conversations)
                } else {
                    //Create new conversation
                    self?.database.child("\(otherUserUid)/conversations").setValue([recipientNewConversationData])
                }
            })
            
            //Update current user conversation entry
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                //Conversation array exists for current user, append
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name,
                                                     conversationID: conversationId,
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
                    self?.finishCreatingConversation(name: name,
                                                     conversationID: conversationId,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                })
            }
        }
    }
    
    /// Fetches and returns all conversations for the user with passed in uid
    public func getAllConversations(forUid uid: String, completion: @escaping(Result<[Conversation], Error>) -> Void) {
        database.child("\(uid)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let conversations: [Conversation] = value.compactMap ({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserUid = dictionary["other_user_uid"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"]  as? Bool else { return nil }
                
                
                let latestMessageObject = LatestMessage(date: date,
                                                        text: message,
                                                        isRead: isRead)
                
                return Conversation(id: conversationId,
                                    name: name,
                                    otherUserUid: otherUserUid,
                                    latestMessage: latestMessageObject)
            })
            completion(.success(conversations))
        })
    }
    
    /// Get all messages for a given conversation
    public func getAllMessagesForConversation(with id: String, completion: @escaping(Result<[Message], Error>) -> Void) {
        database.child("\(id)/messages").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let messages: [Message] = value.compactMap({ dictionary in
                guard let name = dictionary["name"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let messageID = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderUid = dictionary["sender_uid"] as? String,
                      let type = dictionary["type"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let date = ChatViewController.dateFormatter.date(from: dateString) else { return nil }

                var kind: MessageKind?
                if type == "photo" {
                    guard let imageUrl = URL(string: content), let placeHolder = UIImage(systemName: "plus") else { return nil }
                    let media = Media(url: imageUrl,
                                      image: nil,
                                      placeholderImage: placeHolder,
                                      size: CGSize(width: 150, height: 150))
                    kind = .photo(media)
                } else if type == "video" {
                    //Placeholder should be a thumbnail of the video
                    guard let imageUrl = URL(string: content), let placeHolder = UIImage(systemName: "play.circle.fill")?.withTintColor(.clear, renderingMode: .alwaysOriginal) else { return nil }

                    let media = Media(url: imageUrl,
                                      image: nil,
                                      placeholderImage: placeHolder,
                                      size: CGSize(width: 150, height: 150))
                    kind = .video(media)
                    
                    
                }
                else {
                    kind = .text(content)
                }
                
                guard let finalKind = kind else { return nil }
                
                let sender = Sender(userProfileImageUrl: "",
                                    senderId: senderUid,
                                    displayName: name)
                
                return Message(sender: sender,
                               messageId: messageID,
                               sentDate: date,
                               kind: finalKind)
            })
            
            completion(.success(messages))
        })
    }
    
    /// Sends a message with target conversation and message
    public func sendMessage(to conversation: String, name: String, otherUserUid: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
        //Add new message to messages
        //Update sender latest message
        //Update recipient latest message
        
        guard let currentUid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(false)
            return
        }
        
        self.database.child("\(conversation)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else { return }
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            
            let messageDate = newMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch newMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                if let targetUrl = mediaItem.url?.absoluteString {
                    message = targetUrl
                }
                break
            case .video(let mediaItem):
                if let targetUrl = mediaItem.url?.absoluteString {
                    message = targetUrl
                }
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
            
            
            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_uid": currentUserUid,
                "is_read": false,
                "name": name
            ]
            
            currentMessages.append(newMessageEntry)
            
            strongSelf.database.child("\(conversation)/messages").setValue(currentMessages) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                
                strongSelf.database.child("\(currentUid)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    guard var currentUserConversations = snapshot.value as? [[String: Any]] else {
                        completion(false)
                        return
                    }
                    
                    let updatedValue: [String: Any] = [
                        "date": dateString,
                        "is_read": false,
                        "message": message
                    ]
                    
                    var targetConversation: [String: Any]?
                    
                    var position = 0
                    
                    for conversationDictionary in currentUserConversations {
                        if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                            //Update latest message
                            targetConversation = conversationDictionary
                            break
                        }
                        position += 1
                    }
                    
                    targetConversation?["latest_message"] = updatedValue
                    guard let finalConversation = targetConversation else {
                        completion(false)
                        return
                    }

                    currentUserConversations[position] = finalConversation
                    strongSelf.database.child("\(currentUid)/conversations").setValue(currentUserConversations, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                    })
                })
                
                //Update latest message for recipient user
                strongSelf.database.child("\(otherUserUid)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    guard var otherUserConversations = snapshot.value as? [[String: Any]] else {
                        completion(false)
                        return
                    }
                    
                    let updatedValue: [String: Any] = [
                        "date": dateString,
                        "is_read": false,
                        "message": message
                    ]
                    
                    var targetConversation: [String: Any]?
                    
                    var position = 0
                    
                    for conversationDictionary in otherUserConversations {
                        if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                            //Update latest message
                            targetConversation = conversationDictionary
                            break
                        }
                        position += 1
                    }
                    
                    targetConversation?["latest_message"] = updatedValue
                    guard let finalConversation = targetConversation else {
                        completion(false)
                        return
                    }

                    otherUserConversations[position] = finalConversation
                    strongSelf.database.child("\(otherUserUid)/conversations").setValue(otherUserConversations, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                    })
                })
                completion(true)
            }
        })
    }
    
    private func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
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
            "is_read": false,
            "name": name
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
    
    ///Deletes a conversation with conversationID for the target user
    public func deleteConversation(conversationId: String, completion: @escaping (Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        //Get all conversations for current user
        let ref = database.child("\(uid)/conversations")
        ref.observeSingleEvent(of: .value) { snapshot in
            if var conversations = snapshot.value as? [[String: Any]] {
                var positionToRemove = 0
                for conversation in conversations {
                    if let id = conversation["id"] as? String,
                       id == conversationId {
                        break
                    }
                    positionToRemove += 1
                }
                //Delete conversation in collection with target conversationID
                conversations.remove(at: positionToRemove)
                //Reset those conversations for the user in the database
                ref.setValue(conversations) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                }
            }
        }
    }
    
    ///Check if the conversation already exists in conversation list
    public func conversationExists(with targetRecipientUid: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let senderUid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        
    }
}

//Move to models folder
struct ChatUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    let uid: String
    //let profilePictureUrl: URL
}

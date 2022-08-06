//
//  DatabaseManager.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 9/12/21.
//

import UIKit
import FirebaseDatabase
import MessageKit

/// Manager object to read and write data to real time firebase database
final class DatabaseManager {
    
    /// Shared instance of class
    public static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
}

//MARK: - Account Management

extension DatabaseManager {
    
    /// Inserts new user to database with a ChatUser struct
    /// Parameters:
    /// - `user`:   Target user to be inserted to database
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
                    if let _ = error { return }
                }
                
                //completion(true)
                
            } else {
                //create the array - only the first user that gets created
                let newCollection: [[String: String]] = [["name": user.firstName + " " + user.lastName,
                                                          "emailAddress": user.emailAddress,
                                                          "uid": user.uid
                                                         ]]
                self.database.child("users").setValue(newCollection) { error, _ in
                    if let _ = error { return }
                }
                
                //completion(true)
            }
        }
    }
    /*
    public func updateUserCredentials(with user: ChatUser) {
        database.child("\(user.uid)/firstName").setValue(user.firstName)
        database.child("\(user.uid)/firstName").setValue(user.firstName)
    }
     */
    
    
    /// Get all users from database
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
        
        public var localizedDescription: String {
            switch self {
            case .failedToFetch:
                return "Failed to fetch"
            }
        }
    }
}

//MARK: - User recent searches

extension DatabaseManager {
    
    /// Uploads current user recent searches with the field searched
    public func uploadRecentSearches(with searchedTopic: String, completion: @escaping (Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("\(uid)/recentSearches")
        
        // Check if user has recent searches
        ref.observeSingleEvent(of: .value) { snapshot in
            if var recentSearches = snapshot.value as? [String] {
                // Recent searches document exists, append new search
                
                // Check if the searched topic is already saved from the past
                if recentSearches.contains(searchedTopic) {
                    completion(false)
                    return
                }

                if recentSearches.count == 3 {
                    recentSearches.removeFirst()
                    recentSearches.append(searchedTopic)
                } else {
                    recentSearches.append(searchedTopic)
                }
               
                ref.setValue(recentSearches) { error, _ in
                    if let _ = error {
                        completion(false)
                        return
                    }
                }
            } else {
                // First time user searches, create a new document
                ref.setValue([searchedTopic]) { error, _ in
                    if let _ = error {
                        completion(false)
                        return
                    }
                }
            }
            completion(true)
        }
    }
    
    public func fetchRecentSearches(completion: @escaping(Result<[String], Error>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let ref = database.child("\(uid)/recentSearches")
        ref.getData { error, snapshot in
            guard error == nil else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            if let recentSearches = snapshot.value as? [String] {
                completion(.success(recentSearches.reversed()))
            }
        }
    }
}

//MARK: - User Recent Posts

extension DatabaseManager {
    
    public func uploadRecentPost(withUid postUid: String, completion: @escaping (Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("\(uid)/recentPosts")
        
        // Check if user has recent searches
        ref.observeSingleEvent(of: .value) { snapshot in
            if var recentPosts = snapshot.value as? [String] {
                // Recent searches document exists, append new search
                
                if recentPosts.count == 3 {
                    recentPosts.removeFirst()
                    recentPosts.append(postUid)
                } else {
                    recentPosts.append(postUid)
                }
                
                ref.setValue(recentPosts) { error, _ in
                    if let _ = error {
                        completion(false)
                        return
                    }
                }
            } else {
                // First time user searches, create a new document
                ref.setValue([postUid]) { error, _ in
                    if let _ = error {
                        completion(false)
                        return
                    }
                }
            }
            completion(true)
        }
    }
    
    public func fetchRecentPosts(forUid uid: String, completion: @escaping(Result<[String], Error>) -> Void) {
        let ref = database.child("\(uid)/recentPosts")
        ref.getData { error, snapshot in
            guard error == nil else {
                print("error")
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            if let recentPosts = snapshot.value as? [String] {
                completion(.success(recentPosts.reversed()))
            }
        }
    }
}

//MARK: - User Languages

extension DatabaseManager {
    
    public func uploadLanguage(language: String, proficiency: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let ref = database.child("\(uid)/languages")
        
        let languageData = ["languageName": language,
                             "languageProficiency": proficiency]
        
        // Check if user has recent searches
        ref.observeSingleEvent(of: .value) { snapshot in
            if var languages = snapshot.value as? [[String: String]] {
                // Recent searches document exists, append new search
                languages.append(languageData)
                
                ref.setValue(languages) { error, _ in
                    if let _ = error {
                        completion(false)
                        return
                    }
                }
            } else {
                // First time user searches, create a new document
                ref.setValue([languageData]) { error, _ in
                    if let _ = error {
                        completion(false)
                        return
                    }
                }
            }
            completion(true)
        }
    }
    
    public func fetchLanguages(forUid uid: String, completion: @escaping(Result<[[String: String]], Error>) -> Void) {
        let ref = database.child("\(uid)/languages")
        ref.getData { error, snapshot in
            guard error == nil else {
                print("error")
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            if let languages = snapshot.value as? [[String: String]] {
                completion(.success(languages))
            }
        }
    }
}

//MARK: - User Recent Cases

extension DatabaseManager {
    
    public func uploadRecentCase(withUid caseUid: String, completion: @escaping (Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("\(uid)/recentCases")
        
        // Check if user has recent searches
        ref.observeSingleEvent(of: .value) { snapshot in
            if var recentCases = snapshot.value as? [String] {
                // Recent searches document exists, append new search
                
                if recentCases.count == 3 {
                    recentCases.removeFirst()
                    recentCases.append(caseUid)
                } else {
                    recentCases.append(caseUid)
                }
                
                ref.setValue(recentCases) { error, _ in
                    if let _ = error {
                        completion(false)
                        return
                    }
                }
            } else {
                // First time user searches, create a new document
                ref.setValue([caseUid]) { error, _ in
                    if let _ = error {
                        completion(false)
                        return
                    }
                }
            }
            completion(true)
        }
    }
    
    public func fetchRecentCases(forUid uid: String, completion: @escaping(Result<[String], Error>) -> Void) {
        let ref = database.child("\(uid)/recentCases")
        ref.getData { error, snapshot in
            guard error == nil else {
                print("error")
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            if let recentCases = snapshot.value as? [String] {
                print(recentCases)
                completion(.success(recentCases.reversed()))
            }
        }
    }
}

//MARK: - User Sections

extension DatabaseManager {
    public func uploadAboutSection(with aboutText: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("\(uid)/sections/about")
        ref.setValue(aboutText) { error, _ in
            if let _ = error {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    public func fetchAboutSection(forUid uid: String, completion: @escaping(Result<String, Error>) -> Void) {
        let ref = database.child("\(uid)/sections/about")
        ref.getData { error, snapshot in
            guard error == nil else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            if let section = snapshot.value as? String {
                completion(.success(section))
            }
        }
    }
}
    
    
        
        //ref.observeSingleEvent(of: <#T##DataEventType#>, with: <#T##(DataSnapshot) -> Void#>)
        
        /*
         // Check if user has recent searches
         ref.observeSingleEvent(of: .value) { snapshot in
             if var recentSearches = snapshot.value as? [String] {
                 // Recent searches document exists, append new search
                 
                 // Check if the searched topic is already saved from the past
                 if recentSearches.contains(searchedTopic) {
                     completion(false)
                     return
                 }
                 recentSearches.append(searchedTopic)
                 ref.setValue(recentSearches) { error, _ in
                     if let _ = error {
                         completion(false)
                         return
                     }
                 }
             } else {
                 // First time user searches, create a new document
                 ref.setValue([searchedTopic]) { error, _ in
                     if let _ = error {
                         completion(false)
                         return
                     }
                 }
             }
             completion(true)
         }
         */


//MARK: - Sending messages & Conversations
extension DatabaseManager {
    
    /// Creates a new conversation with target user uid and first message sent
    public func createNewConversation(withUid otherUserUid: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
        guard let currentUid = UserDefaults.standard.value(forKey: "uid") as? String,
              let currentName = UserDefaults.standard.value(forKey: "name") as? String else { return }

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
                "creation_date": dateString,
                "other_user_uid": otherUserUid,
                "name": name,
                "latest_message": ["date": dateString,
                                   "message": message,
                                   "is_read": false
                ]
            ]
            
            let recipientNewConversationData: [String: Any] = [
                "id": conversationId,
                "creation_date": dateString,
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
    

    /// Fetches and returns all conversations for the user with uid
    public func getAllConversations(forUid uid: String, completion: @escaping(Result<[Conversation], Error>) -> Void) {
        database.child("\(uid)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let conversations: [Conversation] = value.compactMap ({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let creationDate = dictionary["creation_date"] as? String,
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
                                    creationDate: creationDate,
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
                //if let audioItem = AudioItem. {
                    
                //}
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
                    var databaseEntryConversations = [[String: Any]]()
                    
                    let updatedValue: [String: Any] = [
                        "date": dateString,
                        "is_read": false,
                        "message": message
                    ]
                    
                    if var currentUserConversations = snapshot.value as? [[String: Any]] {
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
                        
                        if var targetConversation = targetConversation {
                            //We fond the conversation, update the conversation & latest message
                            targetConversation["latest_message"] = updatedValue
                            currentUserConversations[position] = targetConversation
                            databaseEntryConversations = currentUserConversations
                        } else {
                            //User must have deleted the conversation and we append as a fresh new entry
                            let newConversationData: [String: Any] = [
                                "id": conversation,
                                "other_user_uid": otherUserUid,
                                "creation_date": dateString,
                                "name": name,
                                "latest_message": updatedValue
                                ]
                            currentUserConversations.append(newConversationData)
                            databaseEntryConversations = currentUserConversations
                        }
                        //There has never been a conversation, create new entry
                    } else {
                        let newConversationData: [String: Any] = [
                            "id": conversation,
                            "other_user_uid": otherUserUid,
                            "creation_date": dateString,
                            "name": name,
                            "latest_message": updatedValue
                            ]
                        databaseEntryConversations = [newConversationData]
                    }
                    
                    strongSelf.database.child("\(currentUid)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                    })
                })
                
                //Update latest message for recipient user
                strongSelf.database.child("\(otherUserUid)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    let updatedValue: [String: Any] = [
                        "date": dateString,
                        "is_read": false,
                        "message": message
                    ]
                    
                    var databaseEntryConversations = [[String: Any]]()
                    guard let currentName = UserDefaults.standard.value(forKey: "name") as? String else { return }
                    
                    if var otherUserConversations = snapshot.value as? [[String: Any]] {
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
                        
                        if var targetConversation = targetConversation {
                            targetConversation["latest_message"] = updatedValue
                            otherUserConversations[position] = targetConversation
                            databaseEntryConversations = otherUserConversations
                        } else {
                            //Failed to find in current collection
                            let newConversationData: [String: Any] = [
                                "id": conversation,
                                "other_user_uid": currentUserUid,
                                "creation_date": dateString,
                                "name": currentName,
                                "latest_message": updatedValue
                                ]
                            otherUserConversations.append(newConversationData)
                            databaseEntryConversations = otherUserConversations
                        }
                    } else {
                        //Current collection does not exist
                        let newConversationData: [String: Any] = [
                            "id": conversation,
                            "other_user_uid": currentUserUid,
                            "creation_date": dateString,
                            "name": currentName,
                            "latest_message": updatedValue
                            ]
                        databaseEntryConversations = [newConversationData]
                    }
                    
                    strongSelf.database.child("\(otherUserUid)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
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
        
        guard let currentUserUid = UserDefaults.standard.value(forKey: "uid") as? String else {
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
    
    /// Check if the conversation already exists in conversation list
    public func conversationExists(with targetRecipientUid: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let senderUid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        //Get the original conversationID between both users
        database.child("\(targetRecipientUid)/conversations").observeSingleEvent(of: .value) { snapshot in
            guard let collection = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            //Iterate and find conversation with target sender
            if let conversation = collection.first(where: {
                guard let targetSenderUid = $0["other_user_uid"] as? String else { return false }
                return senderUid == targetSenderUid
            }) {
                //Get the id
                guard let id = conversation["id"] as? String else {
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }
                completion(.success(id))
                return
            }
            completion(.failure(DatabaseError.failedToFetch))
        }
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

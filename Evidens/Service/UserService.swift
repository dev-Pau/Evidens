//
//  UserService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/10/21.
//

import Firebase
import FirebaseAuth
import Foundation

/// A service used to interface with FirebaseFirestore for user operations.
struct UserService { }


//MARK: - Fetch Operations

extension UserService {
    
    /// Fetches user information for the provided UID.
    ///
    /// - Parameters:
    ///   - uid: The UID of the user to fetch.
    ///   - completion: A completion handler that receives the result of the fetch operation.
    static func fetchUser(withUid uid: String, completion: @escaping(Result<User, FirestoreError>) -> Void) {
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        K.FirestoreCollections.COLLECTION_USERS.document(uid).getDocument { snapshot, error in
            if let error {
                let nsError = error as NSError
                let errCode = FirestoreErrorCode(_nsError: nsError)
                
                switch errCode.code {
                case .notFound:
                    completion(.failure(.notFound))
                default:
                    completion(.failure(.unknown))
                }
            } else {
                guard let dictionary = snapshot?.data() else {
                    completion(.failure(.unknown))
                    return
                    
                }
                
                let user = User(dictionary: dictionary)
                completion(.success(user))
            }
        }
    }
    
    /// Fetches user information for an array of UIDs.
    ///
    /// - Parameters:
    ///   - uids: An array of UIDs for the users to fetch.
    ///   - completion: A completion handler that receives the fetched user information.
    static func fetchUsers(withUids uids: [String], completion: @escaping([User]) -> Void) {
        var users: [User] = []
        uids.forEach { uid in

            K.FirestoreCollections.COLLECTION_USERS.document(uid).getDocument { snapshot, error in
                guard let dictionary = snapshot?.data() else {
                    return
                }
                
                users.append(User(dictionary: dictionary))
                if users.count == uids.count {
                    completion(users)
                }
            }
        }
    }
    
    /// Fetches followers for a given user ID.
    ///
    /// - Parameters:
    ///   - uid: The user ID for which followers need to be fetched.
    ///   - lastSnapshot: The last fetched document snapshot to fetch the next group of followers.
    ///   - completion: A completion handler that returns the result of the fetch operation.
    static func fetchFollowers(forUid uid: String, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        if lastSnapshot == nil {
            
            guard NetworkMonitor.shared.isConnected else {
                completion(.failure(.network))
                return
            }
        
            let firstGroupToFetch = K.FirestoreCollections.COLLECTION_FOLLOWERS.document(uid).collection("user-followers").limit(to: 30)
            firstGroupToFetch.getDocuments { snapshot, error in
                if let error {
                    let nsError = error as NSError
                    let _ = FirestoreErrorCode(_nsError: nsError)
                    completion(.failure(.unknown))
                }
                
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(.failure(.notFound))
                    return
                }
                
                guard snapshot.documents.last != nil else {
                    completion(.success(snapshot))
                    return
                }
                
                completion(.success(snapshot))
            }
        } else {

            let nextGroupToFetch = K.FirestoreCollections.COLLECTION_FOLLOWERS.document(uid).collection("user-followers").start(afterDocument: lastSnapshot!).limit(to: 30)
                
            nextGroupToFetch.getDocuments { snapshot, error in
                if let error {
                    let nsError = error as NSError
                    let _ = FirestoreErrorCode(_nsError: nsError)
                    completion(.failure(.unknown))
                }
                
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(.failure(.notFound))
                    return
                }
                
                guard snapshot.documents.last != nil else {
                    completion(.success(snapshot))
                    return
                }
                
                completion(.success(snapshot))
            }
        }
    }
    
    /// Fetches following data for a given user ID.
    ///
    /// - Parameters:
    ///   - uid: The user ID for which following data needs to be fetched.
    ///   - lastSnapshot: The last fetched document snapshot to fetch the next group of following data.
    ///   - completion: A completion handler that returns the result of the fetch operation.
    static func fetchFollowing(forUid uid: String, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        if lastSnapshot == nil {
            // Fetch first group of posts
            let firstGroupToFetch = K.FirestoreCollections.COLLECTION_FOLLOWING.document(uid).collection("user-following").limit(to: 50)
            firstGroupToFetch.getDocuments { snapshot, error in
                if let error {
                    let nsError = error as NSError
                    let _ = FirestoreErrorCode(_nsError: nsError)
                    completion(.failure(.unknown))
                }
                
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(.failure(.notFound))
                    return
                }
                
                guard snapshot.documents.last != nil else {
                    completion(.success(snapshot))
                    return
                }
                
                completion(.success(snapshot))
            }
        } else {

            let nextGroupToFetch = K.FirestoreCollections.COLLECTION_FOLLOWING.document(uid).collection("user-following").start(afterDocument: lastSnapshot!).limit(to: 50)
                
            nextGroupToFetch.getDocuments { snapshot, error in
                if let error {
                    let nsError = error as NSError
                    let _ = FirestoreErrorCode(_nsError: nsError)
                    completion(.failure(.unknown))
                }
                
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(.failure(.notFound))
                    return
                }
                
                guard snapshot.documents.last != nil else {
                    completion(.success(snapshot))
                    return
                }
                
                completion(.success(snapshot))
            }
        }
    }
    
    /// Fetches a group of users to suggest for the current user to follow.
    ///
    /// - Parameters:
    ///   - user: The current user for whom the suggestions are being fetched.
    ///   - lastSnapshot: The last fetched document snapshot, if available.
    ///   - completion: A completion handler that receives the fetched query snapshot or an error.
    static func fetchUsersToConnect(forUser user: User, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        guard let _ = user.discipline, let uid = user.uid else {
            completion(.failure(.unknown))
            return
        }
        
        if lastSnapshot == nil {
            let firstGroupToFetch = K.FirestoreCollections.COLLECTION_USERS.whereField("uid", isNotEqualTo: uid).whereField("phase", isEqualTo: UserPhase.verified.rawValue).limit(to: 25)

            firstGroupToFetch.getDocuments { snapshot, error in
                if let error {
                    let nsError = error as NSError
                    let _ = FirestoreErrorCode(_nsError: nsError)
                    completion(.failure(.unknown))
                }
                
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(.failure(.notFound))
                    return
                }
                
                guard snapshot.documents.last != nil else {
                    completion(.success(snapshot))
                    return
                }
                
                completion(.success(snapshot))
            }
        } else {

            let nextGroupToFetch = K.FirestoreCollections.COLLECTION_USERS.whereField("uid", isNotEqualTo: uid).whereField("phase", isEqualTo: UserPhase.verified.rawValue).start(afterDocument: lastSnapshot!).limit(to: 25)
                
            nextGroupToFetch.getDocuments { snapshot, error in
                if let error {
                    let nsError = error as NSError
                    let _ = FirestoreErrorCode(_nsError: nsError)
                    completion(.failure(.unknown))
                }
                
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(.failure(.notFound))
                    return
                }
                
                guard snapshot.documents.last != nil else {
                    completion(.success(snapshot))
                    return
                }
                
                completion(.success(snapshot))
            }
        }
    }
    

    /// Fetches a list of users for onboarding.
    ///
    /// - Parameters:
    ///   - completion: A closure to be called when the fetch process is completed.
    ///                 It takes a single parameter of type `Result<[User], FirestoreError>`.
    ///                 The result will be either `.success` with an array of `User` objects containing the onboarding users,
    ///                 or `.failure` with a `FirestoreError` indicating the reason for failure.
    static func fetchOnboardingUsers(completion: @escaping(Result<[User], FirestoreError>) -> Void) {

        K.FirestoreCollections.COLLECTION_USERS.whereField("phase", isEqualTo: UserPhase.verified.rawValue).limit(to: 10).getDocuments { snapshot, error in
            if let error {
                let nsError = error as NSError
                let _ = FirestoreErrorCode(_nsError: nsError)
                completion(.failure(.unknown))
            }
            
            guard let snapshot = snapshot, !snapshot.isEmpty else {
                completion(.failure(.notFound))
                return
            }
            
            let users = snapshot.documents.map { User(dictionary: $0.data() )}
            let filteredUsers = users.filter { $0.isCurrentUser == false }
            completion(.success(filteredUsers))
        }
    }
    
    /// Fetches various statistics for a user from different collections in Firestore.
    ///
    /// - Parameters:
    ///   - uid: The unique identifier of the user for whom to fetch statistics.
    ///   - completion: A closure that will be called once the statistics are retrieved or an error occurs.
    ///                 The closure receives a `Result` object with a `UserStats` object on success
    ///                 and a `FirestoreError` on failure.
    static func fetchUserStats(uid: String, completion: @escaping(Result<UserStats, FirestoreError>) -> Void) {
        
        var stats = UserStats()
        
        var encounteredError = false
        
        let group = DispatchGroup()
        
        group.enter()
        let connectionsRef = K.FirestoreCollections.COLLECTION_CONNECTIONS.document(uid).collection("user-connections").whereField("phase", isEqualTo: ConnectPhase.connected.rawValue).count
        
        connectionsRef.getAggregation(source: .server) { snapshot, error in
            if let _ = error {
                encounteredError = true
            } else {
                if let connections = snapshot?.count {
                    stats.set(connections: connections.intValue)
                } else {
                    stats.set(connections: 0)
                }
            }
            
            group.leave()
        }
        
        group.enter()
        let followersRef = K.FirestoreCollections.COLLECTION_FOLLOWERS.document(uid).collection("user-followers").count
        followersRef.getAggregation(source: .server) { snapshot, error in
            if let _ = error {
                encounteredError = true
            } else {
                if let followers = snapshot?.count {
                    stats.set(followers: followers.intValue)
                } else {
                    stats.set(followers: 0)
                }
            }
            
            group.leave()
        }
        
        group.enter()
        let followingRef = K.FirestoreCollections.COLLECTION_FOLLOWING.document(uid).collection("user-following").count
        followingRef.getAggregation(source: .server) { snapshot, error in
            if let _ = error {
                encounteredError = true
            } else {
                if let following = snapshot?.count {
                    stats.set(following: following.intValue)
                } else {
                    stats.set(following: 0)
                }
            }
            
            group.leave()
        }
        
        group.enter()
        let postsRef = K.FirestoreCollections.COLLECTION_POSTS.whereField("uid", isEqualTo: uid).count
        postsRef.getAggregation(source: .server) { snapshot, error in
            if let _ = error {
                encounteredError = true
            } else {
                if let posts = snapshot?.count {
                    stats.set(posts: posts.intValue)
                } else {
                    stats.set(posts: 0)
                }
            }
            
            group.leave()
        }
        
        group.enter()
        DatabaseManager.shared.checkIfUserHasMoreThanThreeVisibleCases(forUid: uid) { numOfCases in
            stats.set(cases: numOfCases)
            group.leave()
        }
        
        group.notify(queue: .main) {
            if encounteredError {
                completion(.failure(.unknown))
            } else {
                completion(.success(stats))
            }

        }
    }
}

//MARK: - Write Operations

extension UserService {
    
    /// Updates the email of the user with the provided email.
    ///
    /// - Parameters:
    ///   - email: The new email to update.
    static func updateEmail(forUserId userId: String, email: String) {
        K.FirestoreCollections.COLLECTION_USERS.document(userId).updateData(["email" : email.lowercased()])
    }
    
    static func removeImage(kind: ImageKind, completion: @escaping(FirestoreError?) -> Void) {
        guard let uid = UserDefaults.getUid() else { return }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        var path = ""
        
        switch kind {
        case .profile:
            path = "imageUrl"
        case .banner:
            path = "bannerUrl"
        }
        
        K.FirestoreCollections.COLLECTION_USERS.document(uid).updateData([path: FieldValue.delete()]) { error in
            
            if let _ = error {
                completion(.unknown)
            } else {
                StorageManager.deleteImage(kind: kind)
                completion(nil)
            }
        }
    }
}

//MARK: - Miscellaneous

extension UserService {
    
    /// Checks if the current user is following another user.
    ///
    /// - Parameters:
    ///   - uid: The user ID of the user to check if the current user is following.
    ///   - completion: A closure to be called when the check is completed.
    ///                 It takes a single parameter of type `Result<Bool, FirestoreError>`.
    ///                 The result will be either `.success(true)` if the current user is following the specified user,
    ///                 or `.success(false)` if the current user is not following the specified user,
    ///                 or `.failure` with a `FirestoreError` indicating the reason for failure.
    static func checkIfUserIsFollowed(withUid uid: String, completion: @escaping(Result<Bool, FirestoreError>) -> Void) {
        guard let currentUid = UserDefaults.getUid() else {
            completion(.failure(.unknown))
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        
        K.FirestoreCollections.COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid).getDocument { snapshot, error in
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                guard let snapshot = snapshot, snapshot.exists else {
                    completion(.success(false))
                    return
                }
                
                completion(.success(true))
            }
        }
    }
}

//MARK: - Write Operations

extension UserService {
    
    /// Updates the user's banner and/or profile image URLs in the Firestore database.
    ///
    /// - Parameters:
    ///   - bannerUrl: The new banner image URL to be updated. Pass `nil` if you don't want to update the banner URL.
    ///   - profileUrl: The new profile image URL to be updated. Pass `nil` if you don't want to update the profile URL.
    ///   - completion: A closure to be called when the update process is completed.
    ///                 It takes a single parameter of type `User?`, which represents the updated user data if the update is successful,
    ///                 or `nil` if there was an error during the update process.
    static func updateUserImages(withBannerUrl bannerUrl: String? = nil, withProfileUrl profileUrl: String? = nil, completion: @escaping(User?) -> Void) {

        var data = [String: Any]()
        guard let uid = UserDefaults.getUid() else { return }
        if let bannerUrl = bannerUrl { data["bannerUrl"] = bannerUrl }
        if let profileUrl = profileUrl { data["imageUrl"] = profileUrl }

        K.FirestoreCollections.COLLECTION_USERS.document(uid).updateData(data) { error in
            if let _ = error {
                completion(nil)
            } else {
                K.FirestoreCollections.COLLECTION_USERS.document(uid).getDocument { snapshot, error in
                    if let _ = error {
                        completion(nil)
                    } else {
                        guard let dictionary = snapshot?.data() else {
                            completion(nil)
                            return
                        }
                        
                        let user = User(dictionary: dictionary)
                        completion(user)
                    }
                }
            }
        }
    }
    
    /// Update the user's information in Firestore.
    ///
    /// - Parameters:
    ///   - user: The current user object.
    ///   - newUser: The updated user object.
    ///   - completion: A closure to be called when the update is complete. It returns the updated user object on success, or a FirestoreError on failure.
    static func updateUser(from user: User, to newUser: User, completion: @escaping(Result<User, FirestoreError>) -> Void) {
        var data = [String: Any]()
        
        let bannerUrl = (user.bannerUrl! == newUser.bannerUrl!) ? "" : newUser.bannerUrl
        let profileUrl = (user.profileUrl! == newUser.profileUrl!) ? "" : newUser.profileUrl
        let firstName = (user.firstName == newUser.firstName) ? nil : newUser.firstName
        let lastName = (user.lastName == newUser.lastName) ? nil : newUser.lastName
        let speciality = (user.speciality == newUser.speciality) ? nil : newUser.speciality
      
        if bannerUrl != "" {
            data["bannerUrl"] = bannerUrl
        }
        
        if profileUrl != "" {
            data["imageUrl"] = profileUrl
        }
        
        if let firstName = firstName {
            data["firstName"] = firstName.trimmingCharacters(in: .whitespaces)
        }
        
        if let lastName = lastName {
            data["lastName"] = lastName.trimmingCharacters(in: .whitespaces)
        }
        
        if let speciality = speciality {
            data["speciality"] = speciality.rawValue
        }
  
        if data.isEmpty {
            completion(.success(user))
        } else {
            K.FirestoreCollections.COLLECTION_USERS.document(user.uid!).updateData(data) { error in
                if let _ = error {
                    completion(.failure(.unknown))
                } else {
                    K.FirestoreCollections.COLLECTION_USERS.document(user.uid!).getDocument { snapshot, error in
                        if let _ = error {
                            completion(.failure(.unknown))
                        } else {
                            guard let dictionary = snapshot?.data() else {
                                completion(.failure(.unknown))
                                return
                            }
                            
                            var newUser = User(dictionary: dictionary)
                            newUser.stats = user.stats
                            completion(.success(newUser))
                        }
                    }
                }
            }
        }
    }
    
    /// Follows a user with the given UID.
    ///
    /// - Parameters:
    ///   - uid: The UID of the user to follow.
    ///   - completion: A closure to be called when the follow action is completed.
    ///                 It takes a single parameter of type `FirestoreError?`.
    ///                 The parameter will be `nil` if the follow action is successful,
    ///                 or it will contain a `FirestoreError` indicating the reason for failure.
    static func follow(uid: String, completion: @escaping(FirestoreError?) -> Void) {
        guard let currentUid = UserDefaults.getUid() else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let followData = ["timestamp": Timestamp(date: Date())]
        
        let batch = Firestore.firestore().batch()
        
        let followerRef = K.FirestoreCollections.COLLECTION_FOLLOWERS.document(uid).collection("user-followers").document(currentUid)
        let followingRef = K.FirestoreCollections.COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid)
        
        batch.setData(followData, forDocument: followerRef)
        batch.setData(followData, forDocument: followingRef)
        
        batch.commit { error in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
    
    /// Unfollows a user with the given UID.
    ///
    /// - Parameters:
    ///   - uid: The UID of the user to unfollow.
    ///   - completion: A closure to be called when the unfollow action is completed.
    ///                 It takes a single parameter of type `FirestoreError?`.
    ///                 The parameter will be `nil` if the unfollow action is successful,
    ///                 or it will contain a `FirestoreError` indicating the reason for failure.
    static func unfollow(uid: String, completion: @escaping(FirestoreError?) -> Void) {
        guard let currentUid = UserDefaults.getUid() else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let followerRef = K.FirestoreCollections.COLLECTION_FOLLOWERS.document(uid).collection("user-followers").document(currentUid)
        let followingRef = K.FirestoreCollections.COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid)
        
        let batch = Firestore.firestore().batch()
        
        batch.deleteDocument(followerRef)
        batch.deleteDocument(followingRef)
        
        
        batch.commit { error in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
}

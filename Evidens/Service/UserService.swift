//
//  UserService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/10/21.
//

import Firebase
import FirebaseAuth
import Foundation

typealias FirestoreCompletion = (Error?) -> Void

struct UserService {

    /// Updates the email of the user with the provided email.
    ///
    /// - Parameters:
    ///   - email: The new email to update.
    static func updateEmail(email: String) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        COLLECTION_USERS.document(uid).setData(["email" : email.lowercased()], merge: true)
    }
    
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
        
        COLLECTION_USERS.document(uid).getDocument { snapshot, error in
            if let error {
                let nsError = error as NSError
                let errCode = FirestoreErrorCode(_nsError: nsError)
                
                switch errCode.code {
                case .notFound:
                    completion(.failure(.notFound))
                default:
                    completion(.failure(.unknown))
                }
            }
            
            guard let dictionary = snapshot?.data() else {
                completion(.failure(.unknown))
                return
                
            }
            
            let user = User(dictionary: dictionary)
            completion(.success(user))
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
            COLLECTION_USERS.document(uid).getDocument { snapshot, error in
                guard let dictionary = snapshot?.data() else { return }
                users.append(User(dictionary: dictionary))
                if users.count == uids.count {
                    completion(users)
                }
            }
        }
    }
    
    /// Fetches a list of top users based on the given discipline.
    ///
    /// - Parameters:
    ///   - discipline: The discipline for which top users are to be fetched.
    ///   - completion: A completion block that receives the result containing either an array of top users or an error.
    static func fetchTopUsersWithDiscipline(_ discipline: Discipline, completion: @escaping(Result<[User], FirestoreError>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.failure(.unknown))
            return
        }

        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
    
        COLLECTION_USERS.whereField("phase", isEqualTo: UserPhase.verified.rawValue).whereField("discipline", isEqualTo: discipline.rawValue).whereField("uid", isNotEqualTo: uid).limit(to: 3).getDocuments { snapshot, error in
            
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(.failure(.notFound))
                    return
                }
                
                let group = DispatchGroup()
                var users = snapshot.documents.map { User(dictionary: $0.data() )}
                
                for (index, user) in users.enumerated() {
                    group.enter()
                    ConnectionService.getConnectionPhase(uid: user.uid!) { connection in
                        users[index].set(connection: connection)
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    completion(.success(users))
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
        
            let firstGroupToFetch = COLLECTION_FOLLOWERS.document(uid).collection("user-followers").limit(to: 30)
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

            let nextGroupToFetch = COLLECTION_FOLLOWERS.document(uid).collection("user-followers").start(afterDocument: lastSnapshot!).limit(to: 30)
                
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
            let firstGroupToFetch = COLLECTION_FOLLOWING.document(uid).collection("user-following").limit(to: 50)
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

            let nextGroupToFetch = COLLECTION_FOLLOWING.document(uid).collection("user-following").start(afterDocument: lastSnapshot!).limit(to: 50)
                
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
    
    /// Checks if the current user is following another user.
    ///
    /// - Parameters:
    ///   - uid: The UID of the user to check if being followed.
    ///   - completion: A completion handler that receives a boolean indicating if the user is followed.
    static func checkIfUserIsFollowed(uid: String, completion: @escaping(Bool) -> Void) {
        guard let currentUid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid).getDocument { snapshot, error in
            if let _ = error {
                completion(false)
            } else {
                guard let snapshot = snapshot, snapshot.exists else {
                    completion(false)
                    return
                }
                
                completion(true)
            }
        }
    }
    
    /// Fetches a group of users to suggest for the current user to follow.
    ///
    /// - Parameters:
    ///   - user: The current user for whom the suggestions are being fetched.
    ///   - lastSnapshot: The last fetched document snapshot, if available.
    ///   - completion: A completion handler that receives the fetched query snapshot or an error.
    static func fetchUsersToFollow(forUser user: User, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        guard let discipline = user.discipline, let uid = user.uid else {
            completion(.failure(.unknown))
            return
        }
        
        if lastSnapshot == nil {
            let firstGroupToFetch = COLLECTION_USERS.whereField("discipline", isEqualTo: discipline.rawValue).whereField("uid", isNotEqualTo: uid).limit(to: 25)
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

            let nextGroupToFetch = COLLECTION_USERS.whereField("discipline", isEqualTo: discipline.rawValue).whereField("uid", isNotEqualTo: uid).start(afterDocument: lastSnapshot!).limit(to: 25)
                
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
}

// MARK: - Fetch Operations

extension UserService {
    
    /// Fetches suggested users for the current user based on certain conditions.
    ///
    /// - Parameters:
    ///   - completion: A closure to be called when the fetch process is completed.
    ///                 It takes a single parameter of type `Result<[User], FirestoreError>`.
    ///                 The result will be either `.success` with an array of `User` objects containing the suggested users,
    ///                 or `.failure` with a `FirestoreError` indicating the reason for failure.
    static func fetchSuggestedUsers(completion: @escaping(Result<[User], FirestoreError>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        COLLECTION_USERS.whereField("uid", isNotEqualTo: uid).whereField("phase", isEqualTo: UserPhase.verified.rawValue).limit(to: 3).getDocuments { snapshot, error in
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(.failure(.notFound))
                    return
                }
                
                let group = DispatchGroup()
                
                var users = snapshot.documents.map { User(dictionary: $0.data() )}
                
                for (index, user) in users.enumerated() {
                    guard let userUid = user.uid else {
                        continue
                    }
                    
                    group.enter()
                    
                    ConnectionService.getConnectionPhase(uid: userUid) { connection in
                        users[index].set(connection: connection)
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    completion(.success(users))
                }
            }
        }
    }
    
    /// Fetches user network data from Firestore.
    ///
    /// - Parameters:
    ///   - uid: The user ID for which to fetch the network data.
    ///   - lastSnapshot: The last fetched document snapshot (optional). Pass nil to fetch the first batch of data.
    ///   - completion: A closure that will be called once the network data is retrieved or an error occurs.
    ///                 The closure receives a `Result` object with a `QuerySnapshot` on success and a `FirestoreError` on failure.
    static func fetchUserNetwork(forUid uid: String, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        if lastSnapshot == nil {

            let firstGroupToFetch = COLLECTION_FOLLOWERS.document(uid).collection("user-followers").limit(to: 20)
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

            let nextGroupToFetch = COLLECTION_FOLLOWERS.document(uid).collection("user-followers").start(afterDocument: lastSnapshot!).limit(to: 20)
                
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
    
    /// Fetches users whose first or last name contains the provided text.
    ///
    /// - Parameters:
    ///   - text: The text to search for in users' first or last names.
    ///   - completion: A closure that will be called once the users are retrieved or an error occurs.
    ///                 The closure receives a `Result` object with an array of `User` objects on success and a `FirestoreError` on failure.
    static func fetchUsersWithText(_ text: String, completion: @escaping(Result<[User], FirestoreError>) -> Void) {
        var users = [User]()
        
        COLLECTION_USERS.order(by: "firstName").whereField("firstName", isGreaterThanOrEqualTo: text.capitalized).whereField("firstName",
                                                                                                                             isLessThanOrEqualTo: text.capitalized+"\u{f8ff}").limit(to: 20).getDocuments { snapshot, error in
            
            guard let snapshot = snapshot, !snapshot.isEmpty else {
                completion(.failure(.notFound))
                return
            }
            
            let fetchedFirstNameUsers = snapshot.documents.map { User(dictionary: $0.data()) }
            users.append(contentsOf: fetchedFirstNameUsers)
            if fetchedFirstNameUsers.count < 20 {
                let lastNameToFetch = 20 - fetchedFirstNameUsers.count
                
                COLLECTION_USERS.order(by: "lastName").whereField("lastName", isGreaterThanOrEqualTo: text.capitalized).whereField("lastName",
                                                                                                                                   isLessThanOrEqualTo: text.capitalized+"\u{f8ff}").limit(to: lastNameToFetch).getDocuments { snapshot, error in
                    guard let snapshot = snapshot, !snapshot.isEmpty else {
                        completion(.success(users))
                        return
                        
                    }
                    
                    let fetchedLastNameUsers = snapshot.documents.map { User(dictionary: $0.data()) }
                    users.append(contentsOf: fetchedLastNameUsers)
                    completion(.success(users))
                }
            }
        }
    }
    
    /// Fetches the number of followers for the current user.
    ///
    /// - Parameters:
    ///   - completion: A closure to be called when the fetch process is completed.
    ///                 It takes a single parameter of type `Result<Int, FirestoreError>`.
    ///                 The result will be either `.success` with the number of followers as an `Int`,
    ///                 or `.failure` with a `FirestoreError` indicating the reason for failure.
    static func fetchNumberOfFollowers(completion: @escaping(Result<Int, FirestoreError>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let query = COLLECTION_FOLLOWERS.document(uid).collection("user-followers").count
        
        query.getAggregation(source: .server) { snapshot, error in
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                if let likes = snapshot?.count {
                    completion(.success(likes.intValue))
                } else {
                    completion(.success(0))
                }
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

        COLLECTION_USERS.limit(to: 30).getDocuments { snapshot, error in
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
        let connectionsRef = COLLECTION_CONNECTIONS.document(uid).collection("user-connections").whereField("phase", isEqualTo: ConnectPhase.connected.rawValue).count
        
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
        let followersRef = COLLECTION_FOLLOWERS.document(uid).collection("user-followers").count
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
        let followingRef = COLLECTION_FOLLOWING.document(uid).collection("user-following").count
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
        let postsRef = COLLECTION_POSTS.whereField("uid", isEqualTo: uid).count
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
        guard let currentUid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.failure(.unknown))
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        
        COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid).getDocument { snapshot, error in
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
    
    /// Follows a user with the given UID.
    ///
    /// - Parameters:
    ///   - uid: The UID of the user to follow.
    ///   - completion: A closure to be called when the follow action is completed.
    ///                 It takes a single parameter of type `FirestoreError?`.
    ///                 The parameter will be `nil` if the follow action is successful,
    ///                 or it will contain a `FirestoreError` indicating the reason for failure.
    static func follow(uid: String, completion: @escaping(FirestoreError?) -> Void) {
        guard let currentUid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        let followData = ["timestamp": Timestamp(date: Date())]
        
        dispatchGroup.enter()
        
        COLLECTION_FOLLOWERS.document(uid).collection("user-followers").document(currentUid).setData(followData) { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid).setData(followData) { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(nil)
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
        guard let currentUid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid).delete() { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        COLLECTION_FOLLOWERS.document(uid).collection("user-followers").document(currentUid).delete { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(nil)
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
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        if let bannerUrl = bannerUrl { data["bannerImageUrl"] = bannerUrl }
        if let profileUrl = profileUrl { data["imageUrl"] = profileUrl }

        COLLECTION_USERS.document(uid).updateData(data) { error in
            if let _ = error {
                completion(nil)
            } else {
                COLLECTION_USERS.document(uid).getDocument { snapshot, error in
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
            data["firstName"] = firstName
        }
        
        if let lastName = lastName {
            data["lastName"] = lastName
        }
        
        if let speciality = speciality {
            data["speciality"] = speciality
        }
  
        if data.isEmpty {
            completion(.success(user))
        } else {
            COLLECTION_USERS.document(user.uid!).updateData(data) { error in
                if let _ = error {
                    completion(.failure(.unknown))
                } else {
                    COLLECTION_USERS.document(user.uid!).getDocument { snapshot, error in
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
}

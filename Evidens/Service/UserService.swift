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

    static func updateEmail(email: String) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        COLLECTION_USERS.document(uid).setData(["email" : email.lowercased()], merge: true)
    }
    
    static func updateUserFirstName(firstName: String, completion: @escaping(Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(uid).setData(["firstName": firstName.capitalized], merge: true) { err in
            
            if let err = err {
                print("Error writing document: \(err)")
                completion(err)
                return
            } else {
                print("Document succesfully written!")
                completion(nil)
            }
        }
    }
    
    static func updateUserLastName(lastName: String, completion: @escaping(Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(uid).setData(["lastName": lastName.capitalized], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
                completion(err)
            } else {
                print("Document succesfully written!")
                completion(nil)
            }
        }
    }
    
    static func updateProfileImageUrl(profileImageUrl: String, completion: @escaping(Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(uid).updateData(["imageUrl": profileImageUrl], completion: completion)
    }
    
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
    
    static func fetchRelatedUsers(withProfession profession: String, completion: @escaping([User]) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        var usersFetched: [User] = []
        COLLECTION_USERS.whereField("profession", isEqualTo: profession).whereField("uid", isNotEqualTo: uid).limit(to: 10).getDocuments { snapshot, error in
            if let error = error {
                print("error getting documents: \(error)")
            } else {
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion([])
                    return
                }
                
                snapshot.documents.forEach({ document in
                    let dictionary = document.data()
                    
                    usersFetched.append(User(dictionary: dictionary))
                    if usersFetched.count == snapshot.documents.count {
                        completion(usersFetched)
                    }
                })
            }
        }
    }
    
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
    
    static func fetchTopUsersWithTopic(topic: String, completion: @escaping([User]) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        var count = 0
        COLLECTION_USERS.whereField("profession", isEqualTo: topic).whereField("uid", isNotEqualTo: uid).limit(to: 3).getDocuments { snapshot, _ in
            guard let snapshot = snapshot, !snapshot.isEmpty else {
                completion([])
                return
            }

            var users = snapshot.documents.map({ User(dictionary: $0.data() )})
            users.enumerated().forEach { index, user in
                self.checkIfUserIsFollowed(uid: user.uid!) { followed in
                    users[index].isFollowed = followed
                    count += 1
                    if count == users.count {
                        completion(users)
                    }
                }
            }
        }
    }
    
    /*
     static func fetchHomeDocuments(lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
         guard let uid = Auth.auth().currentUser?.uid else { return }
         
         if lastSnapshot == nil {
             // Fetch first group of posts
             let firstGroupToFetch = COLLECTION_USERS.document(uid).collection("user-home-feed").order(by: "timestamp", descending: true).limit(to: 10)
             firstGroupToFetch.getDocuments { snapshot, error in
                 guard let snapshot = snapshot else { return }
                 guard snapshot.documents.last != nil else { return }
                 completion(snapshot)
             }
         } else {
             // Append new posts
             let nextGroupToFetch = COLLECTION_USERS.document(uid).collection("user-home-feed").order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 10)
                 
             nextGroupToFetch.getDocuments { snapshot, error in
                 guard let snapshot = snapshot else { return }
                 guard snapshot.documents.last != nil else { return }
                 completion(snapshot)
             }
         }
     }
     */
    
    static func fetchFollowers(forUid uid: String, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
        if lastSnapshot == nil {
            // Fetch first group of posts
            let firstGroupToFetch = COLLECTION_FOLLOWERS.document(uid).collection("user-followers").limit(to: 50)
            firstGroupToFetch.getDocuments { snapshot, error in
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(snapshot!)
                    return
                }
                guard snapshot.documents.last != nil else {
                    completion(snapshot)
                    return
                }
                completion(snapshot)
            }
        } else {
            // Append new posts
            let nextGroupToFetch = COLLECTION_FOLLOWERS.document(uid).collection("user-followers").start(afterDocument: lastSnapshot!).limit(to: 50)
                
            nextGroupToFetch.getDocuments { snapshot, error in
                guard let snapshot = snapshot else { return }
                guard snapshot.documents.last != nil else { return }
                completion(snapshot)
            }
        }
    }
    
    /*
    static func fetchFollowers(forUid uid: String, completion: @escaping([String?]) -> Void) {
       var userUids = [String]()
        
        COLLECTION_FOLLOWERS.document(uid).collection("user-followers").getDocuments { snapshot, error in
            guard let uids = snapshot?.documents  else {
                return }
            uids.forEach { document in
                userUids.append(document.documentID)
            }
            completion(userUids)
        }
    }
     */
    
    static func fetchFollowing(forUid uid: String, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
        if lastSnapshot == nil {
            // Fetch first group of posts
            let firstGroupToFetch = COLLECTION_FOLLOWING.document(uid).collection("user-following").limit(to: 50)
            firstGroupToFetch.getDocuments { snapshot, error in
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(snapshot!)
                    return
                }
                guard snapshot.documents.last != nil else {
                    completion(snapshot)
                    return
                }
                
                completion(snapshot)
            }
        } else {
            // Append new posts
            let nextGroupToFetch = COLLECTION_FOLLOWING.document(uid).collection("user-following").start(afterDocument: lastSnapshot!).limit(to: 50)
                
            nextGroupToFetch.getDocuments { snapshot, error in
                guard let snapshot = snapshot else { return }
                guard snapshot.documents.last != nil else { return }
                completion(snapshot)
            }
        }
    }
    
    /*
    static func fetchFollowing(forUid uid: String, completion: @escaping([String]) -> Void) {
        var userUids = [String]()
         
         COLLECTION_FOLLOWING.document(uid).collection("user-following").getDocuments { snapshot, error in
             guard let uids = snapshot?.documents  else {
                 return }
             uids.forEach { document in
                 userUids.append(document.documentID)
             }
             completion(userUids)
         }
     }
     */
    
    static func follow(uid: String, completion: @escaping(FirestoreCompletion)) {
        guard let currentUid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let followData = ["timestamp": Timestamp(date: Date())]

        COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid).setData(followData) { error in
            COLLECTION_FOLLOWERS.document(uid).collection("user-followers").document(currentUid).setData(followData, completion: completion)
        }
    }
    
    
    
    static func unfollow(uid: String, completion: @escaping(FirestoreCompletion)) {
        guard let currentUid = UserDefaults.standard.value(forKey: "uid") as? String else { return }

        COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid).delete() { error in
            COLLECTION_FOLLOWERS.document(uid).collection("user-followers").document(currentUid).delete(completion: completion)
        }
    }
    
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
    
    static func fetchUserStats(uid: String, completion: @escaping(UserStats) -> Void) {
        var userStats = UserStats(followers: 0, following: 0, posts: 0, cases: 0)
        
        
        let followersRef = COLLECTION_FOLLOWERS.document(uid).collection("user-followers").count
        followersRef.getAggregation(source: .server) { snapshot, _ in
            if let followers = snapshot?.count {
                userStats.followers = followers.intValue
                
                let followingRef = COLLECTION_FOLLOWING.document(uid).collection("user-following").count
                followingRef.getAggregation(source: .server) { snapshot, _ in
                    if let following = snapshot?.count {
                        userStats.following = following.intValue
                        
                        let postsRef = COLLECTION_POSTS.whereField("uid", isEqualTo: uid).count
                        postsRef.getAggregation(source: .server) { snapshot, _ in
                            if let posts = snapshot?.count {
                                userStats.posts = posts.intValue
                                
                                DatabaseManager.shared.checkIfUserHasMoreThanThreeVisibleCases(forUid: uid) { numOfCases in
                                    userStats.cases = numOfCases
                                    completion(userStats)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

        /*
        COLLECTION_FOLLOWERS.document(uid).collection("user-followers").getDocuments { snapshot, error in
            let followers = snapshot?.documents.count ?? 0
            
            COLLECTION_FOLLOWING.document(uid).collection("user-following").getDocuments { snapshot, error in
                let following = snapshot?.documents.count ?? 0
                
                COLLECTION_POSTS.whereField("ownerUid", isEqualTo: uid).getDocuments { (snapshot, _) in
                    let posts = snapshot?.documents.count ?? 0
                    
                    
                    COLLECTION_CASES.whereField("ownerUid", isEqualTo: uid).getDocuments { snapshot, _ in
                        
                        guard let documents = snapshot?.documents else {
                            completion(UserStats(followers: followers, following: following, posts: posts, cases: 0))
                            return
                        }
                    
                        var cases = documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                        
                        cases.enumerated().forEach { index, clinicalCase in
                            if clinicalCase.privacyOptions == .nonVisible {
                                cases.remove(at: index)
                            }
                        }
                        
                        let numOfCases = cases.count
                        
                        completion(UserStats(followers: followers, following: following, posts: posts, cases: numOfCases))
                        
                    }
                }
            }
        }
         */
    
    
    static func fetchUsersToFollow(forUser user: User, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
        if lastSnapshot == nil {
            // Fetch first group of posts
            // COLLECTION_USERS.whereField("profession", isEqualTo: topic).whereField("uid", isNotEqualTo: uid).limit(to: 3)
            let firstGroupToFetch = COLLECTION_USERS.whereField("profession", isEqualTo: user.discipline!).whereField("uid", isNotEqualTo: user.uid!).limit(to: 25)
            firstGroupToFetch.getDocuments { snapshot, error in
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(snapshot!)
                    return
                }
                guard snapshot.documents.last != nil else {
                    completion(snapshot)
                    return
                    
                }
                
                completion(snapshot)
            }
        } else {
            // Append new posts
            let nextGroupToFetch = COLLECTION_USERS.whereField("profession", isEqualTo: user.discipline!).whereField("uid", isNotEqualTo: user.uid!).start(afterDocument: lastSnapshot!).limit(to: 25)
                
            nextGroupToFetch.getDocuments { snapshot, error in
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(snapshot!)
                    return
                }
                guard snapshot.documents.last != nil else {
                    completion(snapshot)
                    return
                    
                }
                
                completion(snapshot)
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
        
        COLLECTION_USERS.whereField("uid", isNotEqualTo: uid).limit(to: 3).getDocuments { snapshot, error in
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(.failure(.notFound))
                    return
                }
                
                let group = DispatchGroup()
                
                var users = snapshot.documents.map { User(dictionary: $0.data() )}
                
                group.enter()
                
                for (index, user) in users.enumerated() {
                    guard let userUid = user.uid else {
                        group.leave()
                        continue
                    }
                    checkIfUserIsFollowed(uid: userUid) { isFollowed in
                        users[index].isFollowed = isFollowed
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

            let firstGroupToFetch = COLLECTION_FOLLOWING.document(uid).collection("user-following").limit(to: 20)
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

            let nextGroupToFetch = COLLECTION_FOLLOWING.document(uid).collection("user-following").start(afterDocument: lastSnapshot!).limit(to: 20)
                
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
      
        if bannerUrl != "" { data["bannerUrl"] = bannerUrl }
        if profileUrl != "" { data["imageUrl"] = profileUrl }
        if let firstName = firstName {
            data["firstName"] = firstName
            DatabaseManager.shared.updateUserFirstName(firstName: firstName) { _ in }
        }
        if let lastName = lastName { data["lastName"] = lastName
            DatabaseManager.shared.updateUserLastName(lastName: lastName) { _ in }
        }
        if let speciality = speciality { data["speciality"] = speciality }
  
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
                            
                            let user = User(dictionary: dictionary)
                            completion(.success(user))
                        }
                    }
                }
            }
        }
    }
}

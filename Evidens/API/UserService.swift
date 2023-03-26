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
    
    static func updateProfileUrl(profileImageUrl: String, completion: @escaping(Bool) -> Void) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(uid).setData(["profileImageUrl" : profileImageUrl], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
                completion(false)
                return
            } else {
                print("Document succesfully written!")
                completion(true)
            }
        }
    }
    
    static func updateBannerUrl(bannerImageUrl: String, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(uid).setData(["bannerImageUrl" : bannerImageUrl], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
                completion(false)
                return
            } else {
                print("Document succesfully written!")
                completion(true)
            }
        }
    }
    
    static func updateUserProfileImages(bannerImageUrl: String? = nil, profileImageUrl: String? = nil, completion: @escaping(User) -> Void) {
        var dataToUpload = [String: Any]()
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        if let bannerImageUrl = bannerImageUrl { dataToUpload["bannerImageUrl"] = bannerImageUrl }
        if let profileImageUrl = profileImageUrl { dataToUpload["profileImageUrl"] = profileImageUrl }

        COLLECTION_USERS.document(uid).updateData(dataToUpload) { error in
            if error != nil { return }
            COLLECTION_USERS.document(uid).getDocument { snapshot, error in
                guard let dictionary = snapshot?.data() else { return }
                let user = User(dictionary: dictionary)
                completion(user)
            }
        }
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
        COLLECTION_USERS.document(uid).updateData(["profileImageUrl": profileImageUrl], completion: completion)
    }
    
    static func fetchUser(withUid uid: String, completion: @escaping(User) -> Void) {
        COLLECTION_USERS.document(uid).getDocument { snapshot, error in
            guard let dictionary = snapshot?.data() else { return }
            
            let user = User(dictionary: dictionary)
            completion(user)
        }
    }
    
    static func updateUser(from user: User, to newUser: User, completion: @escaping(User) -> Void) {
        // Check what profile values have changed
        var updatedProfileData = [String: Any]()
        
        let bannerUrl = (user.bannerImageUrl! == newUser.bannerImageUrl!) ? "" : newUser.bannerImageUrl
        let profileUrl = (user.profileImageUrl! == newUser.profileImageUrl!) ? "" : newUser.profileImageUrl
        let firstName = (user.firstName == newUser.firstName) ? nil : newUser.firstName
        let lastName = (user.lastName == newUser.lastName) ? nil : newUser.lastName
        let speciality = (user.speciality == newUser.speciality) ? nil : newUser.speciality
      
        if bannerUrl != "" { updatedProfileData["bannerImageUrl"] = bannerUrl }
        if profileUrl != "" { updatedProfileData["profileImageUrl"] = profileUrl }
        if let firstName = firstName {
            updatedProfileData["firstName"] = firstName
            DatabaseManager.shared.updateUserFirstName(firstName: firstName) { _ in }
        }
        if let lastName = lastName { updatedProfileData["lastName"] = lastName
            DatabaseManager.shared.updateUserLastName(lastName: lastName) { _ in }
        }
        if let speciality = speciality { updatedProfileData["speciality"] = speciality }
  
        if updatedProfileData.isEmpty {
            completion(user)
            return
        }

        COLLECTION_USERS.document(user.uid!).updateData(updatedProfileData) { error in
            if error != nil { return }
            COLLECTION_USERS.document(user.uid!).getDocument { snapshot, error in
                guard let dictionary = snapshot?.data() else { return }
                let user = User(dictionary: dictionary)
                completion(user)
            }
        }
    }
    
    static func updateUserOnboarding(viewModel: OnboardingViewModel, completion: @escaping(User) -> Void) {
        
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
    
    static func fetchOnboardingUsers(completion: @escaping([User]) -> Void) {
        COLLECTION_USERS.limit(to: 50).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot, !snapshot.isEmpty else {
                completion([])
                return
            }
            
            let users = snapshot.documents.map({ User(dictionary: $0.data()) })
            let filteredUsers = users.filter({ $0.isCurrentUser == false })
            completion(filteredUsers)
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
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid).setData([:]) { error in
            COLLECTION_FOLLOWERS.document(uid).collection("user-followers").document(currentUid).setData([:], completion: completion)
        }
    }
    
    static func unfollow(uid: String, completion: @escaping(FirestoreCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid).delete() { error in
            COLLECTION_FOLLOWERS.document(uid).collection("user-followers").document(currentUid).delete(completion: completion)
        }
    }
    
    static func checkIfUserIsFollowed(uid: String, completion: @escaping(Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid).getDocument { (snapshot, error) in
            //If snapshot exists means user is followed by current user
            guard let isFollowed = snapshot?.exists else { return }
            completion(isFollowed)
        }
    }
    
    #warning("Only for testing purposes, for counting number of likes and display without updating the document field likes")
   
    static func fetchUserFollowerws() {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let query = COLLECTION_FOLLOWERS.document(uid).collection("user-followers").count
        query.getAggregation(source: .server) { snaphsot, _ in
            print(snaphsot?.count)
        }
        
        /*let query = COLLECTION_FOLLOWERS.document(uid).collection("user-followers").count
        do {
            let snapshot = try await query.getAggregation(source: .server)
            print(snapshot.count)
        } catch {
            print(error)
        }
         */
        
        
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
                        
                        let postsRef = COLLECTION_POSTS.whereField("ownerUid", isEqualTo: uid).count
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
    
    static func fetchWhoToFollowUsers(completion: @escaping([User]) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        var users = [User]()
        var count: Int = 0
        COLLECTION_USERS.whereField("uid", isNotEqualTo: uid).limit(to: 3).getDocuments { snapshot, error in
            guard let snapshot = snapshot, !snapshot.isEmpty else {
                completion(users)
                return
            }

            users = snapshot.documents.map({ User(dictionary: $0.data()) })
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
    
    static func fetchUsersToFollow(forUser user: User, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {

        if lastSnapshot == nil {
            // Fetch first group of posts
            let firstGroupToFetch = COLLECTION_USERS.whereField("profession", isEqualTo: user.profession!).limit(to: 25)
            firstGroupToFetch.getDocuments { snapshot, error in
                guard let snapshot = snapshot else { return }
                guard snapshot.documents.last != nil else { return }
                completion(snapshot)
            }
        } else {
            // Append new posts
            let nextGroupToFetch = COLLECTION_USERS.whereField("profession", isEqualTo: user.profession!).start(afterDocument: lastSnapshot!).limit(to: 25)
                
            nextGroupToFetch.getDocuments { snapshot, error in
                guard let snapshot = snapshot else { return }
                guard snapshot.documents.last != nil else { return }
                completion(snapshot)
            }
        }
    }

    static func fetchUsersWithText(text: String, completion: @escaping([User]) -> Void) {
        var users = [User]()
        
        COLLECTION_USERS.order(by: "firstName").whereField("firstName", isGreaterThanOrEqualTo: text.capitalized).whereField("firstName",
                                                                                                                             isLessThanOrEqualTo: text.capitalized+"\u{f8ff}").limit(to: 20).getDocuments { snapshot, error in
         
            guard let snapshot = snapshot else {completion(users)
                return
            }
            let fetchedFirstNameUsers = snapshot.documents.map({ User(dictionary: $0.data()) })
            users.append(contentsOf: fetchedFirstNameUsers)
            if fetchedFirstNameUsers.count < 20 {
                let lastNameToFetch = 20 - fetchedFirstNameUsers.count
                
                COLLECTION_USERS.order(by: "lastName").whereField("lastName", isGreaterThanOrEqualTo: text.capitalized).whereField("lastName",
                                                                                                                                   isLessThanOrEqualTo: text.capitalized+"\u{f8ff}").limit(to: lastNameToFetch).getDocuments { snapshot, error in
                    
                    guard let snapshot = snapshot else {
                        completion(users)
                        return
                        
                    }
                    let fetchedLastNameUsers = snapshot.documents.map({ User(dictionary: $0.data()) })
                    users.append(contentsOf: fetchedLastNameUsers)
                    completion(users)
                }
                
            }
        }
    }
}


//
//  UserProfileViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/10/23.
//

import UIKit
import Firebase

/// The viewModel for a UserProfile.
class UserProfileViewModel {
    
    private(set) var user: User
    private(set) var uid: String?
    
    var isFirstLoad: Bool = false
    
    var postsLoaded: Bool = false
    var casesLoaded: Bool = false
    var repliesLoaded: Bool = false
   
    var networkFailure: Bool = false
    
    var postLastTimestamp: Int64?
    var caseLastTimestamp: Int64?
    var replyLastTimestamp: Int64?
    
    var selectedImage: UIImageView!
    
    var index = 0
    
    var posts = [Post]()
    var cases = [Case]()
    var replies = [ProfileComment]()
    
    var about = String()
    var website = String()

    var isFetchingOrDidFetchPosts: Bool = false
    var isFetchingOrDidFetchReplies: Bool = false
   
    private var isFetchingMorePosts: Bool = false
    private var isFetchingMoreCases: Bool = false
    private var isFetchingMoreReplies: Bool = false
    
    var isScrollingHorizontally = false
    var collectionsLoaded: Bool = false
    
    var currentNotification: Bool = false
    
    private var fetchPostLimit: Bool = false
    private var fetchCaseLimit: Bool = false
    private var fetchReplyLimit: Bool = false
    
    init(user: User) {
        self.user = user
    }
    
    init(uid: String) {
        self.user = User(dictionary: [:])
        self.uid = uid
    }
    
    func set(user: User) {
        self.user = user
    }
    
    func set(isFollowed: Bool) {
        self.user.set(isFollowed: isFollowed)
    }
    
    func set(phase: ConnectPhase) {
        self.user.editConnectionPhase(phase: phase)
        
        switch phase {
            
        case .connected:
            user.stats.set(connections: user.stats.connections + 1)
            user.set(isFollowed: true)
        case .pending:
            user.set(isFollowed: true)
        case .received:
            break
        case .rejected:
            break
        case .withdraw:
            break
        case .unconnect:
            user.stats.set(connections: user.stats.connections - 1)
        case .none:
            break
        }
    }
}

//MARK: - Fetch Operations

extension UserProfileViewModel {
    
    func fetchUser(completion: @escaping() -> Void) {
        guard let uid = uid else { return }

        UserService.fetchUser(withUid: uid) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let user):
                strongSelf.user = user
            case .failure(_):
                break
            }
            
            completion()
        }
    }
    
    func fetchUserContent(completion: @escaping(FirestoreError?) -> Void) {
        guard NetworkMonitor.shared.isConnected else {
            networkFailure = true
            completion(.network)
            return
        }
        
        let group = DispatchGroup()
        
        getConnectionPhase(group)
        checkIfUserIsFollowed(group)
        getWebsite(group)
        fetchStats(group)
        fetchCases(group)
        fetchAboutText(group)
        
        group.notify(queue: .main) { [weak self] in
            guard let _ = self else { return }
            completion(nil)
        }
    }
    
    func getFormatUrl() -> String {
        if !website.hasPrefix("https://") && !website.hasPrefix("http://") {
            return "https://" + website
        } else {
            return website
        }
    }
    
    private func getConnectionPhase(_ group: DispatchGroup? = nil) {
        
        if let group {
            group.enter()
        }
        
        ConnectionService.getConnectionPhase(uid: user.uid!) { [weak self] connection in
            guard let strongSelf = self else { return }

            strongSelf.user.set(connection: connection)

            if let group {
                group.leave()
            }
        }
    }
    
    func getWebsite(_ group: DispatchGroup? = nil, completion: (() -> Void)? = nil) {
        
        if let group {
            group.enter()
        }
        
        DatabaseManager.shared.fetchWebsite(forUid: user.uid!) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let website):
                strongSelf.website = website
            case .failure(_):
                strongSelf.website = String()
            }
            
            
            if let group {
                group.leave()
            }
            
            completion?()
        }
    }
    
    private func checkIfUserIsFollowed(_ group: DispatchGroup? = nil) {
        
        if let group {
            group.enter()
        }
        
        UserService.checkIfUserIsFollowed(withUid: user.uid!) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let isFollowed):
                strongSelf.user.set(isFollowed: isFollowed)
            case .failure(_):
                break
            }

            if let group {
                group.leave()
            }
        }
    }
    
    private func fetchStats(_ group: DispatchGroup? = nil) {
        
        if let group {
            group.enter()
        }
        
        UserService.fetchUserStats(uid: user.uid!) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let stats):
                strongSelf.user.stats = stats
            case .failure(let error):
                switch error {
                case .network:
                    break
                default:
                    break
                }
            }
            
            if let group {
                group.leave()
            }
        }
    }
    
    //func fetchPosts(_ group: DispatchGroup? = nil) {
    func fetchPosts(completion: @escaping () -> Void) {
        guard let uid = user.uid else { return }
        
        isFetchingOrDidFetchPosts = true
        
        DatabaseManager.shared.getUserPosts(lastTimestampValue: nil, forUid: uid) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let postIds):
                
                if postIds.count < 10 {
                    strongSelf.fetchPostLimit = true
                }
                
                PostService.fetchPosts(withPostIds: postIds) { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                    case .success(let posts):
                        strongSelf.posts = posts
                        strongSelf.postLastTimestamp = strongSelf.posts.last?.timestamp.seconds
                    case .failure(_):
                        strongSelf.posts.removeAll()
                        break
                    }

                    strongSelf.postsLoaded = true
                    
                    completion()
                }
            case .failure(_):
                strongSelf.posts.removeAll()
                strongSelf.postsLoaded = true
                strongSelf.fetchPostLimit = true
                
                completion()
            }
        }
    }
    
    //func fetchCases(completion: @escaping () -> Void) {
    func fetchCases(_ group: DispatchGroup? = nil) {
        guard let uid = user.uid else { return }
        
        if let group {
            group.enter()
        }
        
        //isFetchingOrDidFetchCases = true
        
        DatabaseManager.shared.getRecentCaseIds(lastTimestampValue: nil, forUid: uid) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let caseIds):
                
                if caseIds.count < 10 {
                    strongSelf.fetchCaseLimit = true
                }
                
                CaseService.fetchCases(withCaseIds: caseIds) { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                    case .success(let cases):
                        strongSelf.cases = cases
                        strongSelf.caseLastTimestamp = strongSelf.cases.last?.timestamp.seconds
                    case .failure(_):
                        strongSelf.cases.removeAll()
                        break
                    }
                    
                    strongSelf.casesLoaded = true
                    
                    if let group {
                        group.leave()
                    }
                }
                
            case .failure(_):
                strongSelf.cases.removeAll()
                strongSelf.fetchCaseLimit = true
                strongSelf.casesLoaded = true
                
                if let group {
                    group.leave()
                }
            }
        }
    }
    
    func fetchComments(completion: @escaping () -> Void) {
        guard let uid = user.uid else { return }
        isFetchingOrDidFetchReplies = true
        DatabaseManager.shared.fetchRecentComments(lastTimestampValue: nil, forUid: uid) { [weak self] result in
            
            guard let strongSelf = self else { return }
            switch result {
            case .success(let replies):
                strongSelf.replies = replies
                strongSelf.replyLastTimestamp = Int64(strongSelf.replies.last?.timestamp ?? 0)
            case .failure(_):
                strongSelf.replies.removeAll()
            }
            
            if strongSelf.replies.count < 10 {
                strongSelf.fetchReplyLimit = true
            }
            
            strongSelf.repliesLoaded = true
            completion()
        }
    }
    
    func fetchAboutText(_ group: DispatchGroup? = nil, completion: (() -> Void)? = nil) {
        guard let uid = user.uid else { return }
        
        if let group {
            group.enter()
        }
        
        DatabaseManager.shared.fetchAboutUs(forUid: uid) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let about):
                strongSelf.about = about
            case .failure(_):
                strongSelf.about = ""
            }
            
            if let group {
                group.leave()
            }
            
            completion?()
        }
    }
}

//MARK: - Pagination

extension UserProfileViewModel {
    
    func fetchMorePosts(completion: @escaping () -> Void) {
        guard !isFetchingMorePosts, !fetchPostLimit, !posts.isEmpty else { return }
        
        showBottomSpinner(for: .posts)
        
        DatabaseManager.shared.getUserPosts(lastTimestampValue: postLastTimestamp, forUid: user.uid!) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let postIds):
               
                if postIds.count < 10 {
                    strongSelf.fetchPostLimit = true
                }
                
                PostService.fetchPosts(withPostIds: postIds) { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                    case .success(let posts):
                        
                        strongSelf.posts.append(contentsOf: posts)
                        strongSelf.postLastTimestamp = strongSelf.posts.last?.timestamp.seconds
                    case .failure(_):
                        break
                    }
                    
                    strongSelf.hideBottomSpinner(for: .posts)
                    completion()
                    
                }
            case .failure(_):
                strongSelf.fetchPostLimit = true
                strongSelf.hideBottomSpinner(for: .cases)
            }
        }
    }
    
    func fetchMoreCases(completion: @escaping () -> Void) {
        guard !isFetchingMoreCases, !fetchCaseLimit, !cases.isEmpty else { return }
        
        showBottomSpinner(for: .cases)
        
        DatabaseManager.shared.getRecentCaseIds(lastTimestampValue: caseLastTimestamp, forUid: user.uid!) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let caseIds):
                
                if caseIds.count < 10 {
                    strongSelf.fetchCaseLimit = true
                }
                
                CaseService.fetchCases(withCaseIds: caseIds) { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                    case .success(let cases):
                        strongSelf.cases.append(contentsOf: cases)
                        strongSelf.caseLastTimestamp = strongSelf.cases.last?.timestamp.seconds
                    case .failure(_):
                        break
                    }
                    
                    strongSelf.hideBottomSpinner(for: .cases)
                    completion()
                }
                
            case .failure(_):
                strongSelf.fetchCaseLimit = true
                strongSelf.hideBottomSpinner(for: .cases)
            }
        }
    }
    
    func fetchMoreReplies(completion: @escaping () -> Void) {

        guard !isFetchingMoreReplies, !fetchReplyLimit, !replies.isEmpty else { return }
        
        guard let uid = user.uid else { return }
        
        showBottomSpinner(for: .reply)

        DatabaseManager.shared.fetchRecentComments(lastTimestampValue: replyLastTimestamp, forUid: uid) { [weak self] result in

            guard let strongSelf = self else { return }
            switch result {
            case .success(let replies):
                
                if replies.count < 10 {
                    strongSelf.fetchReplyLimit = true
                }
                
                strongSelf.replies.append(contentsOf: replies)
                strongSelf.replyLastTimestamp = Int64(strongSelf.replies.last?.timestamp ?? 0)
                completion()
                
            case .failure(_):
                strongSelf.fetchReplyLimit = true
            }
            
            strongSelf.hideBottomSpinner(for: .reply)

        }
    }
}

//MARK: - Miscellaneous

extension UserProfileViewModel {
    
    func website(_ url: String) -> AttributedString {
        var container = AttributeContainer()

        container.font = UIFont.addFont(size: 13, scaleStyle: .largeTitle, weight: .medium)
        container.foregroundColor = .label
        
        return AttributedString(url, attributes: container)
    }
    
    private func showBottomSpinner(for section: ProfileSection) {
        switch section {
            
        case .posts:
            isFetchingMorePosts = true
        case .cases:
            isFetchingMoreCases = true
        case .reply:
            isFetchingMoreReplies = true
        }
    }
    
    private func hideBottomSpinner(for section: ProfileSection) {
        switch section {
            
        case .posts:
            isFetchingMorePosts = false
        case .cases:
            isFetchingMoreCases = false
        case .reply:
            isFetchingMoreReplies = false
        }
    }
    
    func hasWeeksPassedSince(forWeeks weeks: Int, timestamp: Timestamp) -> Bool {
        let timestampDate = timestamp.dateValue()
        
        let currentDate = Date()
        
        let weeksAgo = Calendar.current.date(byAdding: .weekOfYear, value: -weeks, to: currentDate)
        
        return timestampDate <= weeksAgo!
    }
}

// MARK: - Connections

extension UserProfileViewModel {
    
    func connect(completion: @escaping(FirestoreError?) -> Void) {
        
        guard let uid = user.uid else {
            completion(.unknown)
            return
        }
        
        ConnectionService.connect(withUid: uid) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                completion(error)
            } else {
                strongSelf.user.editConnectionPhase(phase: .pending)
                completion(nil)
            }
        }
    }
    
    func withdraw(completion: @escaping(FirestoreError?) -> Void) {
        guard let uid = user.uid else {
            completion(.unknown)
            return
        }
        
        ConnectionService.withdraw(forUid: uid) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                completion(error)
            } else {
                strongSelf.user.editConnectionPhase(phase: .withdraw)
                completion(nil)
            }
        }
    }
    
    func accept(currentUser: User, completion: @escaping(FirestoreError?) -> Void) {
        guard let uid = user.uid else {
            completion(.unknown)
            return
        }
        
        ConnectionService.accept(forUid: uid, user: user) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                completion(error)
            } else {
                strongSelf.user.editConnectionPhase(phase: .connected)
                strongSelf.user.stats.set(connections: strongSelf.user.stats.connections + 1)
                completion(nil)
            }
        }
    }
    
    func unconnect(completion: @escaping(FirestoreError?) -> Void) {
        guard let uid = user.uid else {
            completion(.unknown)
            return
        }
        
        ConnectionService.unconnect(withUid: uid) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                completion(error)
            } else {
                strongSelf.user.editConnectionPhase(phase: .unconnect)
                strongSelf.user.stats.set(connections: strongSelf.user.stats.connections - 1)
                completion(nil)
            }
        }
    }
}

//MARK: - Follow

extension UserProfileViewModel {
    
    func follow(completion: @escaping(FirestoreError?) -> Void) {
        UserService.follow(uid: user.uid!) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                completion(error)
            } else {
                strongSelf.user.set(isFollowed: true)
                strongSelf.user.stats.set(followers: strongSelf.user.stats.followers + 1)
                completion(nil)
            }
        }
    }
    
    func unfollow(completion: @escaping(FirestoreError?) -> Void) {
        UserService.unfollow(uid: user.uid!) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                completion(error)
            } else {
                strongSelf.user.set(isFollowed: false)
                strongSelf.user.stats.set(followers: strongSelf.user.stats.followers - 1)
                completion(nil)
            }
        }
    }
    
    func followText() -> String {
        return AppStrings.PopUp.follow + AppStrings.Characters.space + user.getUsername()
    }
    
    func unfollowText() -> String {
        return AppStrings.PopUp.unfollow + AppStrings.Characters.space + user.getUsername()
    }
    
    func removeConnectionText() -> String {
        return AppStrings.PopUp.removeConnection + AppStrings.Characters.space + user.getUsername()
    }
    
    func sendConnectionText() -> String {
        return AppStrings.PopUp.sendConnection + AppStrings.Characters.space + user.getUsername()
    }
    
    func acceptConnectionText() -> String {
        return AppStrings.PopUp.acceptConnection
    }
    
    func withdrawConnectionText() -> String {
        return AppStrings.PopUp.withdrawConnection
    }
}

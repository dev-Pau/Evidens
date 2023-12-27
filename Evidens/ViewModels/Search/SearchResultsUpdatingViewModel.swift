//
//  SearchResultsUpdatingViewMode.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/10/23.
//

import Foundation
import Firebase
import Typesense

protocol SearchResultsUpdatingViewModelDelegate: AnyObject {
    func suggestionsDidUpdate()
    func topResultsDidUpdate()
    func peopleDidUpdate()
    func postsDidUpdate()
    func casesDidUpdate()
}

/// The viewModel for a SearchResultsUpdating.
class SearchResultsUpdatingViewModel {
    
    weak var delegate: SearchResultsUpdatingViewModelDelegate?
    
    var searchMode: SearchMode = .recents
    var searchTopic: SearchTopics = .people
    
    var suggestions = [Suggestion]()
    
    var scrollIndex = 0
    var isScrollingHorizontally: Bool = false
    
    var isFirstLoad: Bool = false
    
    var isFetchingOrDidFetchPosts = false
    var isFetchingOrDidFetchCases = false
    var isFetchingOrDidFetchPeople = false
    
    var firstPeopleLoad = true
    var firstPostsLoad = true
    var firstCasesLoad = true
    
    var pagePeople = 1
    var pagePosts = 1
    var pageCases = 1
    
    var searchedText = ""
    var searchedDiscipline: Discipline?
    
    var searchTimer: Timer?

    var isFetchingMoreContent: Bool = false
 
    var searches = [String]()
    var users = [User]()
    
    var currentNotification: Bool = false
    
    var topUsers = [User]()
    private var usersLastSnapshot: QueryDocumentSnapshot?
    
    var topPosts = [Post]()
    var topPostUsers = [User]()
    private var postsLastSnapshot: QueryDocumentSnapshot?
    
    var topCases = [Case]()
    var topCaseUsers = [User]()
    private var caseLastSnapshot: QueryDocumentSnapshot?
    
    var people = [User]()
    
    var posts = [Post]()
    var postUsers = [User]()
    
    var cases = [Case]()
    var caseUsers = [User]()
    
    var selectedImage: UIImageView!
    
    var searchLoaded: Bool = false
    
    var featuredLoaded: Bool = false
    var peopleLoaded: Bool = false
    var postsLoaded: Bool = false
    var casesLoaded: Bool = false
    
    func getRecentSearches(completion: @escaping () -> Void) {
        
        let group = DispatchGroup()
        
        group.enter()
        DatabaseManager.shared.fetchRecentSearches { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let searches):
                strongSelf.searches = searches
                
            case .failure(let error):
                guard error != .empty else {
                    group.leave()
                    return
                }
            }

            group.leave()
        }
        
        group.enter()
        DatabaseManager.shared.fetchRecentUserSearches { [weak self] result in
            guard let _ = self else { return }
            switch result {
                
            case .success(let uids):
                UserService.fetchUsers(withUids: uids) { [weak self] users in
                    guard let strongSelf = self else { return }
                    strongSelf.users = users
                    group.leave()
                }
            case .failure(let error):
                guard error != .empty else {
                    group.leave()
                    return
                }
                
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.searchLoaded = true
            completion()
        }
    }
    
    func getSuggestionsWithText() async {
        do {
            suggestions = try await TypeSearchService.shared.search(with: searchedText)
            delegate?.suggestionsDidUpdate()
        } catch FirestoreError.network {
            suggestions.removeAll()
        } catch {
            suggestions.removeAll()
        }
    }
    
    func getFeaturedContentForText() async {
    
        isFetchingOrDidFetchPosts = false
        isFetchingOrDidFetchCases = false
        isFetchingOrDidFetchPeople = false
        
        do {
            async let users = searchUsers()
            async let posts = searchTopPosts()
            async let cases = searchTopCases()
            
            (topUsers, topPosts, topCases) = try await (users, posts, cases)
            featuredLoaded = true
            delegate?.topResultsDidUpdate()
        } catch {
            
        }
    }
    
    private func searchUsers() async throws -> [User] {
        
        let users = try await TypeSearchService.shared.searchUsers(with: searchedText, perPage: 3, page: 1)

        if users.isEmpty {
            return []
        } else {
            let uids = users.map { $0.id }
            
            let searchUsers = await withCheckedContinuation { continuation in
                UserService.fetchUsers(withUids: uids) { users in

                    ConnectionService.getConnectionPhase(forUsers: users) { users in
                        continuation.resume(returning: users)
                    }
                }
            }
            
            return searchUsers
        }
    }
    
    private func searchTopPosts() async throws -> [Post] {
        
        let posts = try await TypeSearchService.shared.searchPosts(with: searchedText, page: 1, perPage: 3)
        
        if posts.isEmpty {
            return []
        } else {
            let postIds = posts.map { $0.id }
            
            let searchPosts = await withCheckedContinuation { continuation in

                PostService.fetchPosts(withPostIds: postIds) { result in
                    switch result {
                    case .success(let posts):

                        let uids = Array(Set(posts.map { $0.uid }))
                        UserService.fetchUsers(withUids: uids) { [weak self] users in
                            guard let strongSelf = self else { return }
                            strongSelf.topPostUsers = users
                            continuation.resume(returning: posts)
                        }

                    case .failure(_):
                        continuation.resume(returning: [])
                    }
                }
            }
            
            return searchPosts
        }
    }
    
    private func searchTopCases() async throws -> [Case] {
        
        let cases = try await TypeSearchService.shared.searchCases(with: searchedText, page: 1, perPage: 3)
        
        if cases.isEmpty {
            return []
        } else {
            let caseIds = cases.map { $0.id }
            
            let searchCases = await withCheckedContinuation { continuation in

                CaseService.fetchCases(withCaseIds: caseIds) { [weak self] result in
                    guard let _ = self else { return }
                    switch result {
    
                    case .success(let cases):
                        
                        let regularCases = cases.filter { $0.privacy == .regular }
                        
                        if regularCases.isEmpty {
                            continuation.resume(returning: cases)
                        } else {
                            let uids = Array(Set(regularCases.map { $0.uid }))

                            UserService.fetchUsers(withUids: uids) { [weak self] users in
                                guard let strongSelf = self else { return }
                                strongSelf.topCaseUsers = users
                                continuation.resume(returning: cases)
                            }
                        }
                    case .failure(_):
                        continuation.resume(returning: [])
                    }
                }
            }
            
            return searchCases
        }
    }
    
    func searchPeople() async throws {
        isFetchingOrDidFetchPeople = true
        
        let users = try await TypeSearchService.shared.searchUsers(with: searchedText, perPage: 10, page: pagePeople)

        if users.isEmpty {
            if firstPeopleLoad {
                peopleLoaded = true
                delegate?.peopleDidUpdate()
                firstPeopleLoad = false
            }
        } else {
            let uids = users.map { $0.id }
            
            let searchUsers = await withCheckedContinuation { continuation in
                UserService.fetchUsers(withUids: uids) { [weak self] users in
                    guard let strongSelf = self else { return }
                    ConnectionService.getConnectionPhase(forUsers: users) { users in
                        strongSelf.pagePeople += 1
                        continuation.resume(returning: users)
                    }
                }
            }
            
            peopleLoaded = true
            firstPeopleLoad = false
            people.append(contentsOf: searchUsers)
            delegate?.peopleDidUpdate()
        }
    }
    
    func searchPosts() async throws {
        isFetchingOrDidFetchPosts = true
        
        let posts = try await TypeSearchService.shared.searchPosts(with: searchedText, page: pagePosts, perPage: 5)
        
        if posts.isEmpty {
            if firstPostsLoad {
                postsLoaded = true
                delegate?.postsDidUpdate()
                firstPostsLoad = false
            }
        } else {
            let postIds = posts.map { $0.id }
            
            let searchPosts = await withCheckedContinuation { continuation in

                PostService.fetchPosts(withPostIds: postIds) { result in
                    switch result {
                    case .success(let posts):

                        let uids = Array(Set(posts.map { $0.uid }))
                        UserService.fetchUsers(withUids: uids) { [weak self] users in
                            guard let strongSelf = self else { return }
                            strongSelf.postUsers.append(contentsOf: users)
                            strongSelf.pagePosts += 1
                            continuation.resume(returning: posts)
                        }

                    case .failure(_):
                        continuation.resume(returning: [])
                    }
                }
            }
            
            postsLoaded = true
            firstPostsLoad = false
            self.posts.append(contentsOf: searchPosts)
            delegate?.postsDidUpdate()
        }
    }
    
    func searchCases() async throws {
        isFetchingOrDidFetchCases = true
        
        let cases = try await TypeSearchService.shared.searchCases(with: searchedText, page: pageCases, perPage: 3)

        if cases.isEmpty {
            if firstCasesLoad {
                casesLoaded = true
                delegate?.casesDidUpdate()
                firstCasesLoad = false
            }
        } else {
            let caseIds = cases.map { $0.id }
            
            let searchCases = await withCheckedContinuation { continuation in

                CaseService.fetchCases(withCaseIds: caseIds) { [weak self] result in
                    guard let strongSelf = self else { return }
                    
                    switch result {

                    case .success(let cases):
                        
                        let regularCases = cases.filter { $0.privacy == .regular }
                        
                        if regularCases.isEmpty {
                            strongSelf.pageCases += 1
                            continuation.resume(returning: cases)
                        } else {
                            let uids = Array(Set(regularCases.map { $0.uid }))

                            UserService.fetchUsers(withUids: uids) { [weak self] users in
                                guard let strongSelf = self else { return }
                                strongSelf.pageCases += 1
                                strongSelf.caseUsers.append(contentsOf: users)
                                continuation.resume(returning: cases)
                            }
                        }
                    case .failure(_):
                        continuation.resume(returning: [])
                    }
                }
            }
            
            casesLoaded = true
            firstCasesLoad = false
            self.cases.append(contentsOf: searchCases)
            delegate?.casesDidUpdate()
        }
    }
    
    func reset() {
        isFetchingOrDidFetchPosts = true
        isFetchingOrDidFetchCases = true
        isFetchingOrDidFetchPeople = true
        
        scrollIndex = 0

        topUsers.removeAll()
        topCases.removeAll()
        topPosts.removeAll()
        
        topCaseUsers.removeAll()
        topPostUsers.removeAll()
        
        people.removeAll()

        posts.removeAll()
        postUsers.removeAll()
        
        cases.removeAll()
        caseUsers.removeAll()
        
        featuredLoaded = false
        peopleLoaded = false
        postsLoaded = false
        casesLoaded = false
        
        firstPeopleLoad = true
        firstPostsLoad = true
        firstCasesLoad = true
        
        pagePeople = 1
        pagePosts = 1
        pageCases = 1
    }
}


//MARK: - Miscellaneous

extension SearchResultsUpdatingViewModel {
    
    func hasWeeksPassedSince(forWeeks weeks: Int, timestamp: Timestamp) -> Bool {
        let timestampDate = timestamp.dateValue()
        
        let currentDate = Date()
        
        let weeksAgo = Calendar.current.date(byAdding: .weekOfYear, value: -weeks, to: currentDate)
        
        return timestampDate <= weeksAgo!
    }
}

//MARK: - Miscellaneous

extension SearchResultsUpdatingViewModel {
    
    private func showBottomSpinner() {
        isFetchingMoreContent = true
    }
    
    private func hideBottomSpinner() {
        isFetchingMoreContent = false
    }
}

//MARK: - Network

extension SearchResultsUpdatingViewModel {
    
    func connect(withUser user: User, completion: @escaping(FirestoreError?) -> Void) {
        
        guard let uid = user.uid else {
            completion(.unknown)
            return
        }
        
        ConnectionService.connect(withUid: uid) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                completion(error)
            } else {
                
                if let index = strongSelf.topUsers.firstIndex(where: { $0.uid == user.uid }) {
                    strongSelf.topUsers[index].editConnectionPhase(phase: .pending)
                }

                completion(nil)
            }
        }
    }
    
    func withdraw(withUser user: User, completion: @escaping(FirestoreError?) -> Void) {
        guard let uid = user.uid else {
            completion(.unknown)
            return
        }
        
        ConnectionService.withdraw(forUid: uid) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                completion(error)
            } else {
                
                if let index = strongSelf.topUsers.firstIndex(where: { $0.uid == user.uid }) {
                    strongSelf.topUsers[index].editConnectionPhase(phase: .withdraw)
                }

                completion(nil)
            }
        }
    }
    
    func accept(withUser user: User, currentUser: User, completion: @escaping(FirestoreError?) -> Void) {
        guard let uid = user.uid else {
            completion(.unknown)
            return
        }
        
        ConnectionService.accept(forUid: uid, user: user) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                completion(error)
            } else {
                
                if let index = strongSelf.topUsers.firstIndex(where: { $0.uid == user.uid }) {
                    strongSelf.topUsers[index].editConnectionPhase(phase: .connected)
                    strongSelf.topUsers[index].stats.set(connections: strongSelf.topUsers[index].stats.connections + 1)
                }
                
                completion(nil)
            }
        }
    }
    
    func unconnect(withUser user: User, completion: @escaping(FirestoreError?) -> Void) {
        guard let uid = user.uid else {
            completion(.unknown)
            return
        }
        
        ConnectionService.unconnect(withUid: uid) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                completion(error)
            } else {

                if let index = strongSelf.topUsers.firstIndex(where: { $0.uid == user.uid }) {
                    strongSelf.topUsers[index].editConnectionPhase(phase: .unconnect)
                    strongSelf.topUsers[index].stats.set(connections: strongSelf.topUsers[index].stats.connections - 1)
                }
                
                completion(nil)
            }
        }
    }
}

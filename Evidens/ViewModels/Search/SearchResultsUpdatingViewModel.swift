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
    
    func fetchContentFor(discipline: Discipline, searchTopic: SearchTopics, completion: @escaping () -> Void) {
        
        //dataLoaded = false
        //networkIssue = false
        
        SearchService.fetchContentWithDisciplineAndTopic(discipline: discipline, searchTopic: searchTopic, lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                switch searchTopic {
                    
                case .people:
                    strongSelf.usersLastSnapshot = snapshot.documents.last
                    var users = snapshot.documents.map { User(dictionary: $0.data() )}

                    let uids = users.map { $0.uid! }
                    let group = DispatchGroup()
                    
                    for (index, uid) in uids.enumerated() {
                        group.enter()
                        
                        ConnectionService.getConnectionPhase(uid: uid) { connection in
                            users[index].set(connection: connection)
                            group.leave()
                        }
                    }
                    
                    group.notify(queue: .main) { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.topUsers = users
                        //strongSelf.dataLoaded = true
                        completion()
                    }
                case .posts:
                    strongSelf.postsLastSnapshot = snapshot.documents.last
                    let posts = snapshot.documents.map { Post(postId: $0.documentID, dictionary: $0.data()) }
                    
                    PostService.getPostValuesFor(posts: posts) { [weak self] values in
                        strongSelf.topPosts = values
                        
                        let uids = Array(Set(values.map { $0.uid }))

                        UserService.fetchUsers(withUids: uids) { [weak self] users in
                            guard let strongSelf = self else { return }
                            strongSelf.topPostUsers = users
                            //strongSelf.dataLoaded = true
                            completion()
                        }
                    }

                case .cases:
                    strongSelf.caseLastSnapshot = snapshot.documents.last
                    let cases = snapshot.documents.map { Case(caseId: $0.documentID, dictionary: $0.data() )}
                    
                    CaseService.getCaseValuesFor(cases: cases) { [weak self] values in
                        strongSelf.topCases = values
                        
                        let uids = cases.filter { $0.privacy == .regular }.map { $0.uid }

                        guard uids.isEmpty else {
                            //strongSelf.dataLoaded = true
                            completion()
                            return
                        }
                        
                        UserService.fetchUsers(withUids: uids) { [weak self] users in
                            guard let strongSelf = self else { return }
                            strongSelf.topCaseUsers = users
                            //strongSelf.dataLoaded = true
                            completion()
                        }
                    }
                case .featured:
                    break
                }
            case .failure(_):

                switch searchTopic {
                    
                case .people:
                    strongSelf.topUsers.removeAll()
                case .posts:
                    strongSelf.topPosts.removeAll()
                case .cases:
                    strongSelf.topCases.removeAll()
                case .featured:
                    break
                }
                
                //strongSelf.dataLoaded = true
                //strongSelf.networkIssue = error == .network ? true : false
                completion()
            }
        }
    }
    
    func getTopFor(discipline: Discipline, completion: @escaping () -> Void) {
        //networkIssue = false
        //dataLoaded = false
        let group = DispatchGroup()
        
        group.enter()
        UserService.fetchTopUsersWithDiscipline(discipline) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let users):
                strongSelf.topUsers = users
            case .failure(let error):
                if error != .notFound {
                    if error == .network {
                        //strongSelf.networkIssue = true
                    }
                } else {
                    strongSelf.topUsers.removeAll()
                }
            }
            
            group.leave()
        }
        
        group.enter()
        PostService.fetchTopPostsWithDiscipline(discipline) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let posts):
                
                let uids = Array(Set(posts.map { $0.uid }))
                
                UserService.fetchUsers(withUids: uids) { [weak self] users in
                    guard let strongSelf = self else { return }
                    strongSelf.topPosts = posts
                    strongSelf.topPostUsers = users
                    group.leave()
                }
            case .failure(let error):
                if error != .notFound {
                    if error == .network {
                        //strongSelf.networkIssue = true
                    }
                } else {
                    strongSelf.topPosts.removeAll()
                    strongSelf.topPostUsers.removeAll()
                }

                group.leave()
            }
        }
        
        group.enter()
        CaseService.fetchTopCasesWithDiscipline(discipline) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let cases):
                
                let visibleCases = cases.filter { $0.privacy == .regular }
                let uids = Array(Set(visibleCases.map { $0.uid }))
                
                UserService.fetchUsers(withUids: uids) { [weak self] users in
                    guard let strongSelf = self else { return }
                    strongSelf.topCases = cases
                    strongSelf.topCaseUsers = users
                    group.leave()
                }
                
            case .failure(let error):
                if error != .notFound {
                    if error == .network {
                        //strongSelf.networkIssue = true
                    }
                } else {
                    strongSelf.topCases.removeAll()
                    strongSelf.topCaseUsers.removeAll()
                }
                
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let _ = self else { return }
            completion()
        }
    }
    
    func fetchMoreContent(for discipline: Discipline, completion: @escaping () -> Void) {
        
        guard !isFetchingMoreContent else {
            return
        }
        
        var lastSnapshot: QueryDocumentSnapshot?
        
        switch searchTopic {
            
        case .people:
            guard !topUsers.isEmpty else {
                return
            }
            
            lastSnapshot = usersLastSnapshot
            
        case .posts:
            guard !topPosts.isEmpty else {
                return
            }
            
            lastSnapshot = postsLastSnapshot
        case .cases:
            guard !topCases.isEmpty else {
                return
            }
            
            lastSnapshot = caseLastSnapshot
        case .featured:
            break
        }
        
        showBottomSpinner()
        
        SearchService.fetchContentWithDisciplineAndTopic(discipline: discipline, searchTopic: searchTopic, lastSnapshot: lastSnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                switch strongSelf.searchTopic {
                    
                case .people:
                    strongSelf.usersLastSnapshot = snapshot.documents.last
                    var users = snapshot.documents.map { User(dictionary: $0.data() )}

                    let uids = users.map { $0.uid! }
                    let group = DispatchGroup()
                    
                    for (index, uid) in uids.enumerated() {
                        group.enter()
                        UserService.checkIfUserIsFollowed(withUid: uid) { [weak self] result in
                            guard let _ = self else { return }
                            switch result {
                                
                            case .success(let isFollowed):
                                users[index].set(isFollowed: isFollowed)
                            case .failure(_):
                                users[index].set(isFollowed: false)
                            }
                            
                            group.leave()
                        }
                    }
                    
                    group.notify(queue: .main) { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.topUsers.append(contentsOf: users)
                        strongSelf.hideBottomSpinner()
                        completion()
                    }
                case .posts:
                    strongSelf.postsLastSnapshot = snapshot.documents.last
                    let posts = snapshot.documents.map { Post(postId: $0.documentID, dictionary: $0.data()) }
                    
                    PostService.getPostValuesFor(posts: posts) { [weak self] values in
                        strongSelf.topPosts.append(contentsOf: values)
                        
                        let uids = Array(Set(values.map { $0.uid }))
                        
                        let currentUids = strongSelf.topPostUsers.map { $0.uid }
                        
                        let uidsToFetch = uids.filter { !currentUids.contains($0) }
                        
                        guard !uidsToFetch.isEmpty else {
                            strongSelf.hideBottomSpinner()
                            completion()
                            return
                        }

                        UserService.fetchUsers(withUids: uids) { [weak self] users in
                            guard let strongSelf = self else { return }
                            strongSelf.topPostUsers.append(contentsOf: users)
                            strongSelf.hideBottomSpinner()
                            completion()
                        }
                    }

                case .cases:
                    strongSelf.caseLastSnapshot = snapshot.documents.last
                    let cases = snapshot.documents.map { Case(caseId: $0.documentID, dictionary: $0.data() )}
                    
                    CaseService.getCaseValuesFor(cases: cases) { [weak self] values in
                        strongSelf.topCases.append(contentsOf: values)
                        
                        let uids = cases.filter { $0.privacy == .regular }.map { $0.uid }
                        
                        let currentUids = strongSelf.topCaseUsers.map { $0.uid }
                        
                        let uidsToFetch = uids.filter { !currentUids.contains($0) }
                        
                        guard uidsToFetch.isEmpty else {
                            strongSelf.hideBottomSpinner()
                            completion()
                            return
                        }
                        
                        UserService.fetchUsers(withUids: uidsToFetch) { [weak self] users in
                            guard let strongSelf = self else { return }
                            strongSelf.topCaseUsers.append(contentsOf: users)
                            strongSelf.hideBottomSpinner()
                            completion()
                        }
                    }
                case .featured:
                    break
                }
            case .failure(_):
                strongSelf.hideBottomSpinner()
            }
        }
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

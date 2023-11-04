//
//  HashtagViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 9/10/23.
//

import Foundation
import Firebase

class HashtagViewModel {
    
    let hashtag: String
    
    var isFirstLoad: Bool = false
    
    var lastCaseSnapshot: QueryDocumentSnapshot?
    var lastPostSnapshot: QueryDocumentSnapshot?
    
    var caseLoaded = false
    var postLoaded = false
    
    var cases = [Case]()
    var caseUsers = [User]()
    
    var posts = [Post]()
    var postUsers = [User]()
    
    var isScrollingHorizontally = false
    var didFetchPosts: Bool = false
    var scrollIndex: Int = 0

    var networkFailure: Bool = false
    
    var isFetchingMoreCases: Bool = false
    var isFetchingMorePosts: Bool = false
    
    init(hashtag: String) {
        self.hashtag = hashtag
    }
    
    
    func getCases(completion: @escaping () -> Void) {
        CaseService.fetchCasesWithHashtag(hashtag.replacingOccurrences(of: "hash:", with: ""), lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                CaseService.fetchCases(snapshot: snapshot) { [weak self] cases in
                    guard let strongSelf = self else { return }
                    strongSelf.lastCaseSnapshot = snapshot.documents.last
                    strongSelf.cases = cases
                    
                    let ownerUids = cases.filter {$0.privacy == .regular }.map { $0.uid }
                    let uniqueUids = Array(Set(ownerUids))

                    guard !uniqueUids.isEmpty else {
                        strongSelf.caseLoaded = true
                        completion()
                        return
                    }
                    
                    UserService.fetchUsers(withUids: uniqueUids) { [weak self] users in
                        guard let strongSelf = self else { return }
                        strongSelf.caseUsers = users
                        strongSelf.caseLoaded = true
                        completion()
                    }
                }
            case .failure(let error):
                strongSelf.networkFailure = error == .network
                strongSelf.caseLoaded = true
                completion()
            }
        }
    }
    
    func getPosts(completion: @escaping () -> Void) {
        didFetchPosts = true
        
        PostService.fetchPostsWithHashtag(hashtag.replacingOccurrences(of: "hash:", with: ""), lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let snapshot):
                PostService.fetchHomePosts(snapshot: snapshot) { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                        
                    case .success(let posts):
                        strongSelf.lastPostSnapshot = snapshot.documents.last
                        strongSelf.posts = posts
                        
                        let ownerUids = Array(Set(posts.map { $0.uid }))
                        
                        UserService.fetchUsers(withUids: ownerUids) { [weak self] users in
                            guard let strongSelf = self else { return }
                            strongSelf.postUsers = users
                            strongSelf.postLoaded = true
                            completion()
                        }
                    case .failure(_):
                        break
                    }
                }
            case .failure(let error):
                strongSelf.networkFailure = error == .network
                strongSelf.postLoaded = true
                completion()
            }
        }
    }
    
    func getMoreCases(completion: @escaping () -> Void) {
        guard !isFetchingMoreCases, !cases.isEmpty, caseLoaded else { return }
        
        showCaseBottomSpinner()
        
        CaseService.fetchCasesWithHashtag(hashtag.replacingOccurrences(of: "hash:", with: ""), lastSnapshot: lastCaseSnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                CaseService.fetchCases(snapshot: snapshot) { [weak self] newCases in
                    guard let strongSelf = self else { return }
                    strongSelf.lastCaseSnapshot = snapshot.documents.last
                    strongSelf.cases.append(contentsOf: newCases)
                    
                    let ownerUids = newCases.map { $0.uid }
                    let currentOwnerUids = strongSelf.caseUsers.map { $0.uid }
                    let newOwnerUids = ownerUids.filter { !currentOwnerUids.contains($0) }
                    
                    guard !newOwnerUids.isEmpty else {
                        strongSelf.isFetchingMoreCases = false
                        strongSelf.hideCaseBottomSpinner()
                        completion()
                        return
                    }
                    
                    UserService.fetchUsers(withUids: newOwnerUids) { [weak self] newUsers in
                        guard let strongSelf = self else { return }
                        strongSelf.caseUsers.append(contentsOf: newUsers)
                        strongSelf.isFetchingMoreCases = false
                        strongSelf.hideCaseBottomSpinner()
                        completion()
                    }
                }
            case .failure(_):
                strongSelf.hideCaseBottomSpinner()
            }
        }
    }
    
    func getMorePosts(completion: @escaping () -> Void) {
        guard !isFetchingMorePosts, !posts.isEmpty, postLoaded else { return }
        
        showPostBottomSpinner()
        
        PostService.fetchPostsWithHashtag(hashtag.replacingOccurrences(of: "hash:", with: ""), lastSnapshot: lastPostSnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                PostService.fetchHomePosts(snapshot: snapshot) { [weak self] result in
                    guard let strongSelf = self else { return }
                    
                    switch result {
                    case .success(let newPosts):
                        strongSelf.lastPostSnapshot = snapshot.documents.last
                        strongSelf.posts.append(contentsOf: newPosts)
                        
                        let ownerUids = newPosts.map { $0.uid }
                        let currentOwnerUids = strongSelf.postUsers.map { $0.uid }
                        let newOwnerUids = ownerUids.filter { !currentOwnerUids.contains($0) }
                        
                        guard !newOwnerUids.isEmpty else {
                            strongSelf.isFetchingMorePosts = false
                            strongSelf.hidePostBottomSpinner()
                            completion()
                            return
                        }
                        
                        UserService.fetchUsers(withUids: newOwnerUids) { [weak self] newUsers in
                            guard let strongSelf = self else { return }
                            strongSelf.postUsers.append(contentsOf: newUsers)
                            strongSelf.isFetchingMorePosts = false
                            strongSelf.hidePostBottomSpinner()
                            completion()
                        }
                    case .failure(_):
                        strongSelf.hidePostBottomSpinner()
                    }
                }
            case .failure(_):
                strongSelf.hidePostBottomSpinner()
            }
        }
    }
}

//MARK: - Miscellaneous

extension HashtagViewModel {
    
    func title() -> String {
        return hashtag.replacingOccurrences(of: "hash:", with: "#")
    }
    
    
    private func showCaseBottomSpinner() {
        isFetchingMoreCases = true
    }
    
    private func hideCaseBottomSpinner() {
        isFetchingMoreCases = false
    }
    
    private func showPostBottomSpinner() {
        isFetchingMorePosts = true
    }
    
    private func hidePostBottomSpinner() {
        isFetchingMorePosts = false
    }
}

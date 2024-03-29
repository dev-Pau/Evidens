//
//  BookmarksViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 9/10/23.
//

import Foundation
import Firebase

/// The viewModel for a Bookmark.
class BookmarksViewModel {
    
    var lastCaseSnapshot: QueryDocumentSnapshot?
    var lastPostSnapshot: QueryDocumentSnapshot?
    
    var isFirstLoad: Bool = false
    var isFirstLayoutLoad: Bool = false
    
    var caseLoaded = false
    var postLoaded = false
    var networkError = false
    
    var cases = [Case]()
    var caseUsers = [User]()
    
    var posts = [Post]()
    var postUsers = [User]()
    
    var selectedImage: UIImageView!
    
    var currentNotification: Bool = false
    
    var isFetchingMoreCases: Bool = false
    var isFetchingMorePosts: Bool = false
    
    var isScrollingHorizontally = false
    var didFetchPosts: Bool = false
    
    var scrollIndex: Int = 0

    func getBookmarkedCases(completion: @escaping() -> Void) {
        
        CaseService.fetchBookmarkedCaseDocuments(lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                
                let caseIds = snapshot.documents.map { $0.documentID }

                CaseService.fetchCases(snapshot: snapshot) { clinicalCases in
                    
                    strongSelf.lastCaseSnapshot = snapshot.documents.last
                    
                    let sortedCases = caseIds.compactMap { caseId in
                        clinicalCases.first { $0.caseId == caseId }
                    }
                    
                    strongSelf.cases = sortedCases
                    
                    let ownerUids = clinicalCases.filter({ $0.privacy == .regular }).map({ $0.uid })
                    
                    guard !ownerUids.isEmpty else {
                        strongSelf.caseLoaded = true
                        completion()
                        return
                    }
                    
                    UserService.fetchUsers(withUids: ownerUids) { users in
                        strongSelf.caseUsers = users
                        strongSelf.caseLoaded = true
                        completion()
                    }
                }
            case .failure(let error):
                strongSelf.networkError = error == .network
                strongSelf.caseLoaded = true
                completion()
            }
        }
    }
    
    func getBookmarkedPosts(completion: @escaping () -> Void) {
        
        didFetchPosts = true
        
        PostService.fetchPostBookmarkDocuments(lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let snapshot):

                let postIds = snapshot.documents.map { $0.documentID }
               
                PostService.fetchPosts(snapshot: snapshot) { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                    case .success(let posts):

                        strongSelf.lastPostSnapshot = snapshot.documents.last
                        
                        let sortedPosts = postIds.compactMap { postId in
                            posts.first { $0.postId == postId }
                        }

                        strongSelf.posts = sortedPosts
                        
                        let ownerUids = posts.map({ $0.uid })
                        
                        UserService.fetchUsers(withUids: ownerUids) { [weak self] users in
                            guard let strongSelf = self else { return }
                            strongSelf.postLoaded = true
                            strongSelf.postUsers = users
                            completion()
                        }
                        
                    case .failure(_):
                        strongSelf.postLoaded = true
                        completion()
                    }
                }
            case .failure(let error):
                strongSelf.postLoaded = true
                strongSelf.networkError = error == .network
                completion()
            }
        }
    }
    
    func getMoreCases(completion: @escaping () -> Void) {
        guard !isFetchingMoreCases, !cases.isEmpty, caseLoaded else {
            return
        }

        showCaseBottomSpinner()
        
        CaseService.fetchBookmarkedCaseDocuments(lastSnapshot: lastCaseSnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                
                let caseIds = snapshot.documents.map { $0.documentID }
                
                CaseService.fetchCases(snapshot: snapshot) { [weak self] cases in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.lastCaseSnapshot = snapshot.documents.last
                    
                    let sortedCases = caseIds.compactMap { caseId in
                        cases.first { $0.caseId == caseId }
                    }
                    
                    strongSelf.cases.append(contentsOf: sortedCases)
                    
                    let uids = cases.filter { $0.privacy == .regular }.map { $0.uid }
                    let currentUids = strongSelf.caseUsers.map { $0.uid }
                    
                    let newUids = uids.filter { !currentUids.contains($0) }
                    
                    guard !newUids.isEmpty else {
                        strongSelf.hideCaseBottomSpinner()
                        completion()
                        return
                    }
                    
                    UserService.fetchUsers(withUids: newUids) { [weak self] newUsers in
                        guard let strongSelf = self else { return }
                        strongSelf.caseUsers.append(contentsOf: newUsers)
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
        
        guard !isFetchingMorePosts, !posts.isEmpty, postLoaded else {
            return
        }
        
        showPostBottomSpinner()
        
        PostService.fetchPostBookmarkDocuments(lastSnapshot: lastPostSnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                
                let postIds = snapshot.documents.map { $0.documentID }
                
                PostService.fetchPosts(snapshot: snapshot) { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                    case .success(let posts):
                        strongSelf.lastPostSnapshot = snapshot.documents.last
                        
                        let sortedPosts = postIds.compactMap { postId in
                            posts.first { $0.postId == postId }
                        }

                        strongSelf.posts.append(contentsOf: sortedPosts)
                        
                        let uids = posts.filter { $0.privacy == .regular }.map { $0.uid }
                        let currentUids = strongSelf.postUsers.map { $0.uid }
                        
                        let newUids = uids.filter { !currentUids.contains($0) }
                        
                        guard !newUids.isEmpty else {
                            strongSelf.hidePostBottomSpinner()
                            completion()
                            return
                        }
                        
                        UserService.fetchUsers(withUids: newUids) { [weak self] newUsers in
                            guard let strongSelf = self else { return }
                            strongSelf.postUsers.append(contentsOf: newUsers)
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

extension BookmarksViewModel {
    
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
    
    func deletePost(forId id: String, completion: @escaping(FirestoreError?) -> Void) {
        PostService.deletePost(withId: id) { [weak self] error in
            guard let _ = self else { return }
            if let error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
}

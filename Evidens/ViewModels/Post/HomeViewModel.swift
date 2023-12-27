//
//  HomeViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/23.
//

import Foundation
import Firebase

/// The viewModel for a Home.
class HomeViewModel {
    
    let source: PostSource

    var discipline: Discipline?
    
    var loaded = false

    var postsLastSnapshot: QueryDocumentSnapshot?
    var postsFirstSnapshot: QueryDocumentSnapshot?
    
    var postLastTimestamp: Int64?
    
    var currentNotification: Bool = false
    
    var selectedImage: UIImageView!
    
    var users = [User]()
    var posts = [Post]()
    
    var lastRefreshTime: Date?
    
    var isFetchingMorePosts: Bool = false
    
    var networkError: Bool = false
    
    
    init(source: PostSource, discipline: Discipline? = nil) {
        self.source = source
        self.discipline = discipline
    }
    
    
    func getFirstGroupOfPosts(completion: @escaping () -> Void) {
        posts.removeAll()
        users.removeAll()
        
        switch source {
        case .home:
            PostService.fetchPostDocuments(lastSnapshot: nil) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                    
                case .success(let snapshot):

                    PostService.fetchPosts(snapshot: snapshot) { [weak self] result in
                        guard let _ = self else { return }
                        switch result {
                        case .success(let fetchedPosts):
                            guard let strongSelf = self else { return }
                            strongSelf.postsFirstSnapshot = snapshot.documents.first
                            strongSelf.postsLastSnapshot = snapshot.documents.last
                            strongSelf.posts = fetchedPosts
                            let uniqueUids = Array(Set(strongSelf.posts.map { $0.uid }))

                            UserService.fetchUsers(withUids: uniqueUids) { [weak self] users in
                                guard let strongSelf = self else { return }
                                
                                strongSelf.users = users
                                strongSelf.networkError = false
                                strongSelf.loaded = true
                                completion()
                            }
                            
                        case .failure(_):
                            completion()
                        }
                    }
                  
                case .failure(let error):
                    strongSelf.networkError = error == .network

                    strongSelf.postsFirstSnapshot = nil
                    strongSelf.postsLastSnapshot = nil
                    strongSelf.loaded = true
                    
                    completion()
                }
            }

        case .search:
            guard let discipline = discipline else { return }
            PostService.fetchSearchDocumentsForDiscipline(discipline: discipline, lastSnapshot: nil) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let snapshot):
                    strongSelf.postsLastSnapshot = snapshot.documents.last
                    strongSelf.posts = snapshot.documents.map({ Post(postId: $0.documentID, dictionary: $0.data()) })
                    
                    PostService.getPostValuesFor(posts: strongSelf.posts) { posts in
                        strongSelf.posts = posts
                        
                        let uids = Array(Set(posts.map { $0.uid }))
                        
                        UserService.fetchUsers(withUids: uids) { [weak self] users in
                            guard let strongSelf = self else { return }
                            strongSelf.users = users
                            strongSelf.networkError = false
                            strongSelf.loaded = true
                            completion()
                        }
                    }
                case .failure(let error):
                    strongSelf.networkError = error == .network

                    strongSelf.postsFirstSnapshot = nil
                    strongSelf.postsLastSnapshot = nil
                    strongSelf.loaded = true
                    
                    completion()
                }
            }
        }
    }
    
    func getMorePosts(completion: @escaping () -> Void) {
        
        guard !isFetchingMorePosts, !posts.isEmpty, loaded else {
            return
        }
        
        showBottomSpinner()

        switch source {
        case .home:
            PostService.fetchPostDocuments(lastSnapshot: postsLastSnapshot) { [weak self] result in
                guard let strongSelf = self else { return }

                switch result {
                case .success(let snapshot):
                    PostService.fetchPosts(snapshot: snapshot) { [weak self] result in
                        guard let strongSelf = self else { return }
                        
                        switch result {
                        case .success(let newPosts):
                            guard let strongSelf = self else { return }
                            strongSelf.postsLastSnapshot = snapshot.documents.last
                            
                            strongSelf.posts.append(contentsOf: newPosts)
                            
                            let uids = newPosts.map { $0.uid }
                            let currentUids = strongSelf.users.map { $0.uid }
                            let newUids = uids.filter { !currentUids.contains($0) }
                            
                            if newUids.isEmpty {
                                strongSelf.networkError = false
                                strongSelf.hideBottomSpinner()
                                completion()
                                return
                            }
                            
                            UserService.fetchUsers(withUids: newUids) { [weak self] users in
                                guard let strongSelf = self else { return }
                                strongSelf.networkError = false
                                strongSelf.users.append(contentsOf: users)
                                strongSelf.hideBottomSpinner()
                                completion()
                            }
                        case .failure(_):
                            strongSelf.hideBottomSpinner()
                        }
                    }
                case .failure(_):
                    strongSelf.hideBottomSpinner()
                }
            }
        
        case .search:
            guard let discipline = discipline else { return }
            PostService.fetchSearchDocumentsForDiscipline(discipline: discipline, lastSnapshot: postsLastSnapshot) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let snapshot):
                    let newPosts = snapshot.documents.map({ Post(postId: $0.documentID, dictionary: $0.data()) })
                    
                    PostService.getPostValuesFor(posts: newPosts) { [weak self] posts in
                        guard let strongSelf = self else { return }
                        strongSelf.posts.append(contentsOf: newPosts)
                        let uids = newPosts.map { $0.uid }
                        let currentUids = strongSelf.users.map { $0.uid }
                        let uniqueUids = uids.filter { !currentUids.contains($0) }
                        
                        UserService.fetchUsers(withUids: uniqueUids) { [weak self] users in
                            guard let strongSelf = self else { return }
                            strongSelf.networkError = false
                            strongSelf.users.append(contentsOf: users)
                            strongSelf.hideBottomSpinner()
                            completion()
                        }
                        
                    }
                case .failure(_):
                    strongSelf.hideBottomSpinner()
                }
            }
        }
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

//MARK: - Miscellaneous

extension HomeViewModel {
    
    private func showBottomSpinner() {
        isFetchingMorePosts = true
    }
    
    private func hideBottomSpinner() {
        isFetchingMorePosts = false
    }
}

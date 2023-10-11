//
//  LikesViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 11/10/23.
//

import Foundation
import Firebase

class LikesViewModel {
    
    let kind: ContentKind
    var post: Post?
    var clinicalCase: Case?
    
    var users = [User]()
    var likesLoaded: Bool = false
    var lastLikesSnapshot: QueryDocumentSnapshot?
    
    var isFetchingMoreLikes: Bool = false
    
    init(post: Post) {
        self.post = post
        self.kind = .post
    }
    
    init(clinicalCase: Case) {
        self.clinicalCase = clinicalCase
        self.kind = .clinicalCase
    }
    
    func getLikes(completion: @escaping () -> Void) {
        switch kind {
        case .post:
            guard let post = post else { return }
            PostService.getAllLikesFor(post: post, lastSnapshot: nil) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                    
                case .success(let snapshot):
                    strongSelf.lastLikesSnapshot = snapshot.documents.last
                    let newUids = snapshot.documents.map({ $0.documentID })
                    let uniqueUids = Array(Set(newUids))
                    
                    UserService.fetchUsers(withUids: uniqueUids) { [weak self] users in
                        guard let strongSelf = self else { return }
                        strongSelf.users = users
                        strongSelf.likesLoaded = true
                        completion()
                    }
                case .failure(_):
                    strongSelf.likesLoaded = true
                    completion()
                }
            }
            
        case .clinicalCase:
            guard let clinicalCase = clinicalCase else { return }
            CaseService.getAllLikesFor(clinicalCase: clinicalCase, lastSnapshot: nil) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                    
                case .success(let snapshot):
                    strongSelf.lastLikesSnapshot = snapshot.documents.last
                    let newUids = snapshot.documents.map({ $0.documentID })
                    let uniqueUids = Array(Set(newUids))
                    
                    UserService.fetchUsers(withUids: uniqueUids) { [weak self] users in
                        guard let strongSelf = self else { return }
                        strongSelf.users = users
                        strongSelf.likesLoaded = true
                        completion()
                    }
                case .failure(_):
                    strongSelf.likesLoaded = true
                    completion()
                }
            }
        }
    }
    
    func getMoreLikes(completion: @escaping() -> Void) {
        
        guard !isFetchingMoreLikes, likesLoaded else { return }
        
        showBottomSpinner()
        
        switch kind {
            
        case .post:
            guard let post = post else { return }
            PostService.getAllLikesFor(post: post, lastSnapshot: lastLikesSnapshot) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                    
                case .success(let snapshot):
                    strongSelf.lastLikesSnapshot = snapshot.documents.last
                    let uids = snapshot.documents.map({ $0.documentID })
                    let currentUids = strongSelf.users.map { $0.uid }
                    let newUids = uids.filter { !currentUids.contains($0) }
                    
                    UserService.fetchUsers(withUids: newUids) { [weak self] users in
                        guard let strongSelf = self else { return }
                        strongSelf.users.append(contentsOf: users)
                        strongSelf.hideBottomSpinner()
                        completion()
                    }
                    
                case .failure(_):
                    strongSelf.hideBottomSpinner()
                    completion()
                }
            }
        case .clinicalCase:
            guard let clinicalCase = clinicalCase else { return }
            CaseService.getAllLikesFor(clinicalCase: clinicalCase, lastSnapshot: lastLikesSnapshot) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                    
                case .success(let snapshot):
                    strongSelf.lastLikesSnapshot = snapshot.documents.last
                    let uids = snapshot.documents.map({ $0.documentID })
                    let currentUids = strongSelf.users.map { $0.uid }
                    let newUids = uids.filter { !currentUids.contains($0) }
                    
                    UserService.fetchUsers(withUids: newUids) { [weak self] users in
                        guard let strongSelf = self else { return }
                        strongSelf.users.append(contentsOf: users)
                        strongSelf.hideBottomSpinner()
                        completion()
                    }
                    
                case .failure(_):
                    strongSelf.hideBottomSpinner()
                    completion()
                }
            }
        }
    }
    
}

//MARK: - Miscellaneous

extension LikesViewModel {
    
    private func showBottomSpinner() {
        isFetchingMoreLikes = true
    }
    
    private func hideBottomSpinner() {
        isFetchingMoreLikes = false
    }
}

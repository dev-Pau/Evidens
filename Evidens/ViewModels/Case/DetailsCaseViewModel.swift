//
//  DetailsCaseViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/23.
//

import UIKit
import Firebase

/// The viewModel for a DetailsCase.
class DetailsCaseViewModel {
    private(set) var caseLoaded: Bool
    
    var clinicalCase: Case
    var user: User?
    var caseId: String?
    
    var firstLoad: Bool = false

    var networkFailure: Bool = false
    
    var currentNotification: Bool = false
    
    var isFetchingMoreComments: Bool = false

    var comments = [Comment]()
    var users = [User]()
    
    var commentsLastSnapshot: QueryDocumentSnapshot?
    var commentsLoaded: Bool = false
   
    var selectedImage: UIImageView!
    
    init(clinicalCase: Case, user: User? = nil) {
        self.clinicalCase = clinicalCase
        self.user = user
        self.caseLoaded = true
    }
    
    init(caseId: String) {
        self.caseId = caseId
        self.clinicalCase = Case(caseId: "", dictionary: [:])
        self.caseLoaded = false
    }
    
    
    func getCase(completion: @escaping(FirestoreError?) -> Void) {
        guard let caseId = caseId else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        CaseService.fetchCase(withCaseId: caseId) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let clinicalCase):
                strongSelf.clinicalCase = clinicalCase
                let uid = clinicalCase.uid
                
                if clinicalCase.privacy == .anonymous {
                    strongSelf.caseLoaded = true
                    completion(nil)
                } else {
                    UserService.fetchUser(withUid: uid) { [weak self] result in
                        guard let strongSelf = self else { return }
                        switch result {
                            
                        case .success(let user):
                            strongSelf.user = user
                            strongSelf.caseLoaded = true
                            completion(nil)
                        case .failure(_):
                            break
                        }
                    }
                }
            case .failure(_):
                break
            }
        }
    }
    
    func getComments(completion: @escaping () -> Void) {

        CommentService.fetchCaseComments(forCase: clinicalCase, forPath: [], lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
               
                strongSelf.commentsLastSnapshot = snapshot.documents.last
                strongSelf.comments = snapshot.documents.map({ Comment(dictionary: $0.data()) })
                
                CommentService.getCaseCommentValuesFor(forCase: strongSelf.clinicalCase, forPath: [], forComments: strongSelf.comments) { [weak self] fetchedComments in
                    guard let strongSelf = self else { return }
                    strongSelf.comments = fetchedComments

                    
                    strongSelf.comments.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                    
                    let userUids = strongSelf.comments.filter { $0.visible == .regular }.map { $0.uid }
                    
                    let uniqueUids = Array(Set(userUids))
                    
                    guard !uniqueUids.isEmpty else {
                        strongSelf.commentsLoaded = true
                        completion()
                        return
                    }
                    
                    UserService.fetchUsers(withUids: userUids) { [weak self] users in
                        guard let strongSelf = self else { return }
                        strongSelf.users = users
                        strongSelf.commentsLoaded = true
                        completion()
                    }
                }
                
            case .failure(let error):
                strongSelf.networkFailure = error == .network
                strongSelf.commentsLoaded = true
                completion()
            }
        }
    }
    
    func getMoreComments(completion: @escaping () -> Void) {
        
        guard commentsLastSnapshot != nil, !comments.isEmpty, !isFetchingMoreComments, commentsLoaded else { return }

        CommentService.fetchCaseComments(forCase: clinicalCase, forPath: [], lastSnapshot: commentsLastSnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let snapshot):

                strongSelf.commentsLastSnapshot = snapshot.documents.last
                var newComments = snapshot.documents.map({ Comment(dictionary: $0.data()) })
                
                CommentService.getCaseCommentValuesFor(forCase: strongSelf.clinicalCase, forPath: [], forComments: newComments) { [weak self] fetchedComments in
                    guard let strongSelf = self else { return }
                    
                    newComments = fetchedComments
                    newComments.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                    
                    strongSelf.comments.append(contentsOf: newComments)
                    let newUserUids = newComments.map { $0.uid }
                    let currentUserUids = strongSelf.users.map { $0.uid }
                    let usersToFetch = newUserUids.filter { !currentUserUids.contains($0) }
                    
                    guard !usersToFetch.isEmpty else {
                        DispatchQueue.main.async { [weak self] in
                            guard let _ = self else { return }
                            completion()
                        }
                        return
                    }
                    
                    UserService.fetchUsers(withUids: usersToFetch) { [weak self] users in
                        guard let _ = self else { return }
                        DispatchQueue.main.async { [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.users.append(contentsOf: users)
                            completion()
                        }
                    }
                }
            case .failure(_):
                break
            }
        }
    }
    
    func deleteCase(completion: @escaping (FirestoreError?) -> Void) {
        CaseService.deleteCase(withId: clinicalCase.caseId, privacy: clinicalCase.privacy) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                completion(error)
            } else {
                strongSelf.clinicalCase.visible = .deleted
                completion(nil)
            }
        }
    }
    
    func deleteComment(forPath path: [String], forCommentId id: String, completion: @escaping(FirestoreError?) -> Void) {
        CommentService.deleteComment(forCase: clinicalCase, forPath: path, forCommentId: id) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                completion(error)
            } else {

                if let index = strongSelf.comments.firstIndex(where: { $0.id == id }) {
                    strongSelf.comments[index].visible = .deleted
                    strongSelf.clinicalCase.numberOfComments -= 1
                    completion(nil)
                } else {
                    completion(.unknown)
                }
            }
        }
    }
    
    func addComment(_ comment: String, from currentUser: User, completion: @escaping(Result<Comment, FirestoreError>) -> Void) {
        CommentService.addComment(comment, for: clinicalCase) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let comment):
                
                strongSelf.clinicalCase.numberOfComments += 1
                
                strongSelf.users.append(currentUser)
                completion(.success(comment))
            
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func editComment(_ comment: String, forId id: String, from currentUser: User, completion: @escaping(FirestoreError?) -> Void) {
        CommentService.editComment(comment, forId: id, for: clinicalCase) { [weak self] error in
            guard let _ = self else { return }
            if let error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
}

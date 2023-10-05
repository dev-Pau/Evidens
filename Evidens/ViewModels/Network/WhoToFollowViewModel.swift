//
//  WhoToFollowViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/23.
//

import Foundation
import Firebase

class WhoToFollowViewModel {
    
    private var user: User
    
    private var usersLastSnapshot: QueryDocumentSnapshot?
    var users = [User]()
    var usersLoaded: Bool = false
    var currentNotification: Bool = false
    
    
    init(user: User) {
        self.user = user
    }
    
    
    func fetchUsersToFollow(completion: @escaping(FirestoreError?) -> Void) {
        
        UserService.fetchUsersToFollow(forUser: user, lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.usersLastSnapshot = snapshot.documents.last
                var users = snapshot.documents.map { User(dictionary: $0.data() ) }
                
                let group = DispatchGroup()
                
                for (index, user) in users.enumerated() {
                    group.enter()
                    UserService.checkIfUserIsFollowed(withUid: user.uid!) { [weak self] result in
                        guard let _ = self else { return }
                        switch result {
                            
                        case .success(let isFollowed):
                            users[index].set(isFollowed: isFollowed)
                        case .failure(_):
                            users[index].isFollowed = false
                        }
                        
                        group.leave()
                    }
                    
                    group.notify(queue: .main) { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.usersLoaded = true
                        strongSelf.users = users
                        completion(nil)
                    }
                }
            case .failure(let error):
                strongSelf.usersLoaded = true
                completion(error)
            }
        }
    }
    
    func getMoreUsers(completion: @escaping () -> Void) {
        UserService.fetchUsersToFollow(forUser: user, lastSnapshot: usersLastSnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.usersLastSnapshot = snapshot.documents.last
                var users = snapshot.documents.map { User(dictionary: $0.data() ) }
                
                let group = DispatchGroup()
                
                for (index, user) in users.enumerated() {
                    group.enter()
                    UserService.checkIfUserIsFollowed(withUid: user.uid!) { [weak self] result in
                        guard let _ = self else { return }
                        switch result {
                            
                        case .success(let isFollowed):
                            users[index].set(isFollowed: isFollowed)
                        case .failure(_):
                            users[index].isFollowed = false
                        }
                        
                        group.leave()
                    }
                    
                    group.notify(queue: .main) { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.users.append(contentsOf: users)
                        completion()
                    }
                }
            case .failure(_):
                return
            }
        }
    }
}

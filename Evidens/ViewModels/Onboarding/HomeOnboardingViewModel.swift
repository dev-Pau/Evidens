//
//  HomeOnboardingViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/10/23.
//

import Foundation

class HomeOnboardingViewModel {
    
    private(set) var user: User
    
    var users = [User]()
    var followersLoaded: Bool = false
    var currentNotification: Bool = false
    
    var count: Int {
        
        return user.phase != .verified ? 0 : followersLoaded ? users.isEmpty ? 1 : users.count : 0
    }

    init(user: User) {
        self.user = user
    }
    
    func fetchUsers(completion: @escaping(FirestoreError?) -> Void) {
        guard user.phase == .verified else {
            followersLoaded = true
            completion(nil)
            return
        }
        
        let group = DispatchGroup()
        
        UserService.fetchOnboardingUsers { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let users):
                strongSelf.users = users
                let uids = strongSelf.users.map { $0.uid! }
                
                var usersToRemove: [User] = []
                
                for (index, uid) in uids.enumerated() {
                    
                    group.enter()
                    
                    UserService.checkIfUserIsFollowed(withUid: uid) { [weak self] result in
                        guard let strongSelf = self else { return }
                        switch result {
                            
                        case .success(let isFollowed):
                            strongSelf.users[index].set(isFollowed: isFollowed)
                        case .failure(_):
                            usersToRemove.append(strongSelf.users[index])
                        }
                        
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    strongSelf.users.removeAll { usersToRemove.contains($0) }
                    
                    strongSelf.followersLoaded = true
                    completion(nil)
                }
                
            case .failure(let error):
                completion(error)
            }
        }
    }
}

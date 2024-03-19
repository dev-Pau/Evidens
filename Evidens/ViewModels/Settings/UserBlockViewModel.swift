//
//  UserBlockViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/3/24.
//

import Foundation
import Firebase

class UserBlockViewModel {
    
    private(set) var lastTimestamp: QueryDocumentSnapshot?
    private(set) var usersLoaded: Bool = false
    private(set) var users: [User] = []
    private(set) var isFetchingMoreUsers: Bool = false

    func getBlockUsers(completion: @escaping () -> ()) {
        BlockService.getBlockUsers(lastSnapshot: lastTimestamp) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                let userIds = snapshot.documents.map { $0.documentID }
                
                strongSelf.lastTimestamp = snapshot.documents.last
                
                guard !userIds.isEmpty else {
                    strongSelf.usersLoaded = true
                    completion()
                    return
                }
                
                UserService.fetchUsers(withUids: userIds) { [weak self] users in
                    guard let strongSelf = self else { return }
                    let validUsers = users.filter { $0.phase == .verified }
                    strongSelf.users = validUsers
                    strongSelf.usersLoaded = true
                    completion()
                }
                
            case .failure(let error):
                if error == .network {
                    break
                } else {
                    strongSelf.usersLoaded = true
                    completion()
                }
            }
        }
    }
    
    func getMoreBlockUsers(completion: @escaping () -> Void) {
        guard !isFetchingMoreUsers, !users.isEmpty, usersLoaded else {
            return
        }

        showUsersBottomSpinner()
        
        BlockService.getBlockUsers(lastSnapshot: lastTimestamp) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                
                let userIds = snapshot.documents.map { $0.documentID }
               
                guard !userIds.isEmpty else {
                    strongSelf.hideUsersBottomSpinner()
                    completion()
                    return
                }
                
                strongSelf.lastTimestamp = snapshot.documents.last
                
                UserService.fetchUsers(withUids: userIds) { [weak self] users in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.users.append(contentsOf: users.filter { $0.phase == .verified })
                    strongSelf.hideUsersBottomSpinner()
                    completion()
                }
            case .failure(_):
                strongSelf.hideUsersBottomSpinner()
            }
        }
    }
}


//MARK: - Miscellaneous

extension UserBlockViewModel {
    
    private func showUsersBottomSpinner() {
        isFetchingMoreUsers = true
    }
    
    private func hideUsersBottomSpinner() {
        isFetchingMoreUsers = false
    }
}

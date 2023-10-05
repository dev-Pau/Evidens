//
//  NewMessageViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/23.
//

import Foundation

class NewMessageViewModel {
    
    var users = [User]()
    var filteredUsers = [User]()
    var usersLoaded: Bool = false
    var isInSearchMode: Bool = false
    
    
    func fetchFollowing(completion: @escaping(FirestoreError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.unknown)
            return
        }
        UserService.fetchFollowing(forUid: uid, lastSnapshot: nil) { [weak self] result in
            
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                let uids = snapshot.documents.map({ $0.documentID })
                UserService.fetchUsers(withUids: uids) { [weak self] users in
                    guard let strongSelf = self else { return }
                    strongSelf.users = users
                    strongSelf.filteredUsers = users
                    strongSelf.usersLoaded = true
                    completion(nil)
                }
            case .failure(let error):
                strongSelf.usersLoaded = true
                completion(error)
            }
        }
    }
    
    func fetchUsersWithText(_ text: String, completion: @escaping () -> Void) {
        UserService.fetchUsersWithText(text.trimmingCharacters(in: .whitespaces)) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let users):
                strongSelf.filteredUsers = users
                
            case .failure(let error):
                if error == .notFound {
                    strongSelf.filteredUsers = []
                }
            }
            
            completion()
        }
    }
}

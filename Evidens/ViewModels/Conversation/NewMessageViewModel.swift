//
//  NewMessageViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/23.
//

import Foundation

protocol NewMessageViewModelDelegate: AnyObject {
    func didSearchUsers()
}

class NewMessageViewModel {
    
    weak var delegate: NewMessageViewModelDelegate?
    
    var users = [User]()
    var filteredUsers = [User]()
    var usersLoaded: Bool = false
    var isInSearchMode: Bool = false
    
    var searchedText = ""

    var hasNetworkConnection: Bool {
        return NetworkMonitor.shared.isConnected
    }
    
    func fetchConnections(completion: @escaping(FirestoreError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.unknown)
            return
        }
        
        ConnectionService.getConnections(forUid: uid, lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let snapshot):
                let uids = snapshot.documents.map { $0.documentID }
                
                UserService.fetchUsers(withUids: uids) { [weak self] users in
                    guard let strongSelf = self else { return }
                    strongSelf.users = users
                    strongSelf.filteredUsers = users
                    strongSelf.usersLoaded = true
                    completion(nil)
                }
            case .failure(let error):
                strongSelf.usersLoaded = true
                if error == .notFound {
                    completion(nil)
                } else {
                    completion(error)
                }
            }
        }
    }
    
    func searchUsers() async {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        do {
            let users = try await TypeSearchService.shared.searchUsers(with: searchedText, perPage: 10, page: 1)
            
            let uids = users.map { $0.id }
            
            guard !uids.isEmpty else {
                filteredUsers = []
                usersLoaded = true
                delegate?.didSearchUsers()
                return
            }
            
            UserService.fetchUsers(withUids: uids) { [weak self] users in
                guard let strongSelf = self else { return }
                strongSelf.filteredUsers = users.filter { $0.uid! != uid }
                strongSelf.usersLoaded = true
                strongSelf.delegate?.didSearchUsers()
            }
        } catch {
            
        }
    }
    
    func getConnectionPhase(forUser user: User, completion: @escaping(Result<ConnectPhase, FirestoreError>) -> Void) {
        guard let uid = user.uid, hasNetworkConnection else {
            completion(.failure(.network))
            return
        }
        
        ConnectionService.getConnectionPhase(uid: uid) { [weak self] connection in
            guard let _ = self else { return }
            completion(.success(connection.phase))
        }
    }
}

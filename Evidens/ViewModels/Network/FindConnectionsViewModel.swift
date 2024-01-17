//
//  FindConnectionsViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/23.
//

import Foundation
import Firebase

/// The viewModel for a FindConnections.
class FindConnectionsViewModel {
    
    private var user: User
    
    private var usersLastSnapshot: QueryDocumentSnapshot?
    var users = [User]()
    var usersLoaded: Bool = false
    var currentNotification = false
    var isFetchingMoreUsers: Bool = false
    
    init(user: User) {
        self.user = user
    }
    

    func fetchUsersToConnect(completion: @escaping(FirestoreError?) -> Void) {
        
        UserService.fetchUsersToConnect(forUser: user, lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.usersLastSnapshot = snapshot.documents.last
                var users = snapshot.documents.map { User(dictionary: $0.data() ) }
                
                let group = DispatchGroup()
                
                for (index, user) in users.enumerated() {
                    guard let userUid = user.uid else {
                        continue
                    }
                    
                    group.enter()
                    
                    ConnectionService.getConnectionPhase(uid: userUid) { [weak self] connection in
                        guard let _ = self else { return }
                        users[index].set(connection: connection)
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.usersLoaded = true
                    strongSelf.users = users
                    completion(nil)
                }
                
            case .failure(let error):
                strongSelf.usersLoaded = true
                completion(error)
            }
        }
    }
    
    func getMoreUsers(completion: @escaping () -> Void) {
        
        guard !isFetchingMoreUsers, !users.isEmpty, usersLoaded else {
            return
        }

        showBottomSpinner()

        UserService.fetchUsersToConnect(forUser: user, lastSnapshot: usersLastSnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.usersLastSnapshot = snapshot.documents.last
                
                var users = snapshot.documents.map { User(dictionary: $0.data() ) }
                
                let group = DispatchGroup()
                
                for (index, user) in users.enumerated() {
                    guard let userUid = user.uid else {
                        continue
                    }
                    
                    group.enter()
                    
                    ConnectionService.getConnectionPhase(uid: userUid) { [weak self] connection in
                        guard let _ = self else { return }
                        users[index].set(connection: connection)
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.users.append(contentsOf: users)
                    strongSelf.usersLoaded = true
                    strongSelf.hideBottomSpinner()
                    completion()
                }
                
            case .failure(_):
                strongSelf.hideBottomSpinner()
                return
            }
        }
    }
}


//MARK: - Miscellaneous

extension FindConnectionsViewModel {
    
    func hasWeeksPassedSince(forWeeks weeks: Int, timestamp: Timestamp) -> Bool {
        let timestampDate = timestamp.dateValue()
        
        let currentDate = Date()
        
        let weeksAgo = Calendar.current.date(byAdding: .weekOfYear, value: -weeks, to: currentDate)
        
        return timestampDate <= weeksAgo!
    }
}

//MARK: - Network

extension FindConnectionsViewModel {
    
    func connect(withUser user: User, completion: @escaping(FirestoreError?) -> Void) {
        
        guard let uid = user.uid else {
            completion(.unknown)
            return
        }
        
        ConnectionService.connect(withUid: uid) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                completion(error)
            } else {
                if let index = strongSelf.users.firstIndex(where: { $0.uid == user.uid }) {
                    strongSelf.users[index].editConnectionPhase(phase: .withdraw)
                }
                completion(nil)
            }
        }
    }
    
    func withdraw(withUser user: User, completion: @escaping(FirestoreError?) -> Void) {
        guard let uid = user.uid else {
            completion(.unknown)
            return
        }
        
        ConnectionService.withdraw(forUid: uid) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                completion(error)
            } else {
                
                if let index = strongSelf.users.firstIndex(where: { $0.uid == user.uid }) {
                    strongSelf.users[index].editConnectionPhase(phase: .withdraw)
                }

                completion(nil)
            }
        }
    }
    
    func accept(withUser user: User, currentUser: User, completion: @escaping(FirestoreError?) -> Void) {
        guard let uid = user.uid else {
            completion(.unknown)
            return
        }
        
        ConnectionService.accept(forUid: uid, user: user) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                completion(error)
            } else {
                
                if let index = strongSelf.users.firstIndex(where: { $0.uid == user.uid }) {
                    strongSelf.users[index].editConnectionPhase(phase: .withdraw)
                }
                
                completion(nil)
            }
        }
    }
    
    func unconnect(withUser user: User, completion: @escaping(FirestoreError?) -> Void) {
        guard let uid = user.uid else {
            completion(.unknown)
            return
        }
        
        ConnectionService.unconnect(withUid: uid) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                completion(error)
            } else {
                
                if let index = strongSelf.users.firstIndex(where: { $0.uid == user.uid }) {
                    strongSelf.users[index].editConnectionPhase(phase: .withdraw)
                }
                
                completion(nil)
            }
        }
    }
}


//MARK: - Miscellaneous

extension FindConnectionsViewModel {
    
    private func showBottomSpinner() {
        isFetchingMoreUsers = true
    }
    
    private func hideBottomSpinner() {
        isFetchingMoreUsers = false
    }
}



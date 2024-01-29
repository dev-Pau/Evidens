//
//  HomeOnboardingViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/10/23.
//

import Foundation
import Firebase

/// The viewModel for a HomeOnboarding.
class HomeOnboardingViewModel {
    
    private(set) var user: User
    
    var users = [User]()
    var followersLoaded: Bool = false
    
    var currentNotification: Bool = false
    
    init(user: User) {
        self.user = user
    }
    
    func fetchUsers(completion: @escaping(FirestoreError?) -> Void) {
        let group = DispatchGroup()
        
        UserService.fetchOnboardingUsers { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let users):
                strongSelf.users = users
                let uids = strongSelf.users.map { $0.uid! }
                
                for (index, uid) in uids.enumerated() {
                    
                    group.enter()
                    
                    ConnectionService.getConnectionPhase(uid: uid) { connection in
                        strongSelf.users[index].set(connection: connection)
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    strongSelf.followersLoaded = true
                    completion(nil)
                }
                
            case .failure(let error):
                completion(error)
            }
        }
    }
}

extension HomeOnboardingViewModel {
    
    func hasWeeksPassedSince(forWeeks weeks: Int, timestamp: Timestamp) -> Bool {
        let timestampDate = timestamp.dateValue()
        
        let currentDate = Date()
        
        let weeksAgo = Calendar.current.date(byAdding: .weekOfYear, value: -weeks, to: currentDate)
        
        return timestampDate <= weeksAgo!
    }
    
    func update(user: User) {
        self.user = user
    }
}

//MARK: - Network

extension HomeOnboardingViewModel {
    
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
                    strongSelf.users[index].editConnectionPhase(phase: .pending)
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
                    strongSelf.users[index].editConnectionPhase(phase: .connected)
                    strongSelf.users[index].stats.set(connections: strongSelf.users[index].stats.connections + 1)
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
                    strongSelf.users[index].editConnectionPhase(phase: .unconnect)
                    strongSelf.users[index].stats.set(connections: strongSelf.users[index].stats.connections - 1)
                }
                
                completion(nil)
            }
        }
    }
}

//
//  UserNetworkViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 8/10/23.
//

import Foundation
import Firebase

class UserNetworkViewModel {
    
    private(set) var user: User
    
    var isFirstLoad: Bool = false
    var isScrollingHorizontally = false
    
    var didFetchFollower: Bool = false
    var didFetchFollowing: Bool = false
    
    var index: Int = 0
    private var connectionLastSnapshot: QueryDocumentSnapshot?
    private var followingLastSnapshot: QueryDocumentSnapshot?
    private var followersLastSnapshot: QueryDocumentSnapshot?
    
    var connectionLoaded: Bool = false
    var followersLoaded: Bool = false
    var followingLoaded: Bool = false

    private var isFetchingMoreConnections: Bool = false
    private var isFetchingMoreFollowers: Bool = false
    private var isFetchingMoreFollowing: Bool = false
    
    var networkError = false

    var currentNotification: Bool = false
    
    var connections = [User]()
    var followers = [User]()
    var following = [User]()
    
    init(user: User) {
        self.user = user
    }
    
    func getConnections(completion: @escaping () -> Void) {
        ConnectionService.getConnections(forUid: user.uid!, lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let snapshot):
                strongSelf.connectionLastSnapshot = snapshot.documents.last
                let connections = snapshot.documents.map { UserConnection(uid: $0.documentID, dictionary: $0.data()) }
                let uids = snapshot.documents.map { $0.documentID }
                
                UserService.fetchUsers(withUids: uids) { [weak self] users in
                    guard let strongSelf = self else { return }
                    strongSelf.connections = users
                    /*
                    for (index, strongConnection) in strongSelf.connections.enumerated() {
                        if let matchingConnection = connections.first(where: { $0.uid == strongConnection.uid }) {
                            strongSelf.connections[index].set(connection: matchingConnection)
                        }
                    }
                    
                    */
                    let uids = users.map { $0.uid! }
                    
                    let group = DispatchGroup()
                    
                    for (index, uid) in uids.enumerated() {
                        group.enter()
                        
                        ConnectionService.getConnectionPhase(uid: uid) { connection in
                            strongSelf.connections[index].set(connection: connection)
                            group.leave()
                        }
                    }
                    
                    group.notify(queue: .main) { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.connectionLoaded = true
                        completion()
                    }
                }
            case .failure(let error):
                strongSelf.networkError = error == .network
                strongSelf.connectionLoaded = true
                completion()
            }
        }
    }
    
    func getFollowers(completion: @escaping () -> Void) {
        didFetchFollower = true
        
        UserService.fetchFollowers(forUid: user.uid!, lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.followersLastSnapshot = snapshot.documents.last
                let uids = snapshot.documents.map { $0.documentID }
                UserService.fetchUsers(withUids: uids) { [weak self] users in
                    guard let strongSelf = self else { return }
                    strongSelf.followers = users
                    
                    let uids = users.map { $0.uid! }
                    
                    let group = DispatchGroup()
                    
                    for (index, uid) in uids.enumerated() {
                        group.enter()
                        
                        ConnectionService.getConnectionPhase(uid: uid) { connection in
                            strongSelf.followers[index].set(connection: connection)
                            group.leave()
                        }
                    }
                    
                    group.notify(queue: .main) { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.followersLoaded = true
                        completion()
                    }
                }
                
            case .failure(let error):
                strongSelf.followersLoaded = true
                strongSelf.networkError = error == .network
                completion()
            }
        }
    }
    
    func getFollowing(completion: @escaping () -> Void) {
        didFetchFollowing = true
        
        UserService.fetchFollowing(forUid: user.uid!, lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.followingLastSnapshot = snapshot.documents.last
                let uids = snapshot.documents.map { $0.documentID }
                UserService.fetchUsers(withUids: uids) { [weak self] users in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.following = users
                    
                    let uids = users.map { $0.uid! }
                    
                    let group = DispatchGroup()
                    
                    for (index, uid) in uids.enumerated() {
                        group.enter()
                        
                        ConnectionService.getConnectionPhase(uid: uid) { connection in
                            strongSelf.following[index].set(connection: connection)
                            group.leave()
                        }
                    }
                    
                    group.notify(queue: .main) { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.followingLoaded = true
                        completion()
                    }
                }
                
            case .failure(let error):
                strongSelf.followingLoaded = true
                strongSelf.networkError = error == .network
                completion()
            }
        }
    }
    
    func getMoreConnections(completion: @escaping () -> Void) {

        guard !isFetchingMoreConnections, !connections.isEmpty else {
            return
        }
        
        showConnectionSpinner()
        
        ConnectionService.getConnections(forUid: user.uid!, lastSnapshot: connectionLastSnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let snapshot):
                strongSelf.connectionLastSnapshot = snapshot.documents.last
                let connections = snapshot.documents.map { UserConnection(uid: $0.documentID, dictionary: $0.data()) }
                let uids = snapshot.documents.map { $0.documentID }
                
                UserService.fetchUsers(withUids: uids) { [weak self] users in
                    guard let strongSelf = self else { return }
                    
                    var newUsers = users
                    
                    for (index, strongConnection) in newUsers.enumerated() {
                        if let matchingConnection = connections.first(where: { $0.uid == strongConnection.uid }) {
                            newUsers[index].set(connection: matchingConnection)
                        }
                    }
                    
                    strongSelf.connections.append(contentsOf: newUsers)
                    strongSelf.hideConnectionSpinner()
                    completion()
                }
            case .failure(_):
                strongSelf.hideConnectionSpinner()
            }
        }
    }
    
    func getMoreFollowers(completion: @escaping () -> Void) {
        
        guard !isFetchingMoreFollowers, !followers.isEmpty else {
            return
        }

        showFollowerSpinner()
        
        UserService.fetchFollowers(forUid: user.uid!, lastSnapshot: followersLastSnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.followersLastSnapshot = snapshot.documents.last
                let uids = snapshot.documents.map { $0.documentID }
                
                UserService.fetchUsers(withUids: uids) { [weak self] users in
                    guard let _ = self else { return }
                
                    var newUsers = users
                    let newUids = users.map { $0.uid! }
                    
                    let group = DispatchGroup()
                    
                    for (index, uid) in newUids.enumerated() {
                        group.enter()
                        
                        ConnectionService.getConnectionPhase(uid: uid) { [weak self] connection in
                            guard let _ = self else { return }
                            newUsers[index].set(connection: connection)
                            group.leave()
                        }
                    }
                    
                    group.notify(queue: .main) { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.followers.append(contentsOf: newUsers)
                        strongSelf.hideFollowerSpinner()
                        completion()
                    }
                }
                
            case .failure(_):
                strongSelf.hideFollowerSpinner()
            }
        }
    }
    
    func getMoreFollowing(completion: @escaping () -> Void) {
        
        guard !isFetchingMoreFollowing, !following.isEmpty else {
            return
        }
        
        showFollowingSpinner()
        
        UserService.fetchFollowing(forUid: user.uid!, lastSnapshot: followingLastSnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.followingLastSnapshot = snapshot.documents.last
                let uids = snapshot.documents.map { $0.documentID }
                
                UserService.fetchUsers(withUids: uids) { [weak self] users in
                    
                    var newUsers = users
                    let newUids = users.map { $0.uid! }
                    
                    let group = DispatchGroup()
                    
                    for (index, uid) in newUids.enumerated() {
                        group.enter()
                        
                        ConnectionService.getConnectionPhase(uid: uid) { [weak self] connection in
                            guard let _ = self else { return }
                            newUsers[index].set(connection: connection)
                            group.leave()
                        }
                    }
                    
                    group.notify(queue: .main) { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.following.append(contentsOf: newUsers)
                        strongSelf.hideFollowingSpinner()
                        completion()
                    }
                }
                
            case .failure(_):
                strongSelf.hideFollowingSpinner()
            }
        }
    }
}

//MARK: - Miscellaneous

extension UserNetworkViewModel {
    
    private func showConnectionSpinner() {
        isFetchingMoreConnections = true
    }
    
    private func hideConnectionSpinner() {
        isFetchingMoreConnections = false
    }
    
    private func showFollowerSpinner() {
        isFetchingMoreFollowers = true
    }
    
    private func hideFollowerSpinner() {
        isFetchingMoreFollowers = false
    }
    
    private func showFollowingSpinner() {
        isFetchingMoreFollowing = true
    }
    
    private func hideFollowingSpinner() {
        isFetchingMoreFollowing = false
    }
}


//MARK: - Miscellaneous

extension UserNetworkViewModel {
    
    func hasWeeksPassedSince(forWeeks weeks: Int, timestamp: Timestamp) -> Bool {
        let timestampDate = timestamp.dateValue()
        
        let currentDate = Date()
        
        let weeksAgo = Calendar.current.date(byAdding: .weekOfYear, value: -weeks, to: currentDate)
        
        return timestampDate <= weeksAgo!
    }
}

//MARK: - Network

extension UserNetworkViewModel {
    
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
                
                if let index = strongSelf.connections.firstIndex(where: { $0.uid == user.uid }) {
                    strongSelf.connections[index].editConnectionPhase(phase: .pending)
                }
                
                if let index = strongSelf.followers.firstIndex(where: { $0.uid == user.uid }) {
                    strongSelf.followers[index].editConnectionPhase(phase: .pending)
                }
                
                if let index = strongSelf.following.firstIndex(where: { $0.uid == user.uid }) {
                    strongSelf.following[index].editConnectionPhase(phase: .pending)
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
                
                if let index = strongSelf.connections.firstIndex(where: { $0.uid == user.uid }) {
                    strongSelf.connections[index].editConnectionPhase(phase: .withdraw)
                }
                
                if let index = strongSelf.followers.firstIndex(where: { $0.uid == user.uid }) {
                    strongSelf.followers[index].editConnectionPhase(phase: .withdraw)
                }

                if let index = strongSelf.following.firstIndex(where: { $0.uid == user.uid }) {
                    strongSelf.following[index].editConnectionPhase(phase: .withdraw)
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
                
                if let index = strongSelf.connections.firstIndex(where: { $0.uid == user.uid }) {
                    strongSelf.connections[index].editConnectionPhase(phase: .connected)
                }
                
                if let index = strongSelf.followers.firstIndex(where: { $0.uid == user.uid }) {
                    strongSelf.followers[index].editConnectionPhase(phase: .connected)
                }

                if let index = strongSelf.following.firstIndex(where: { $0.uid == user.uid }) {
                    strongSelf.following[index].editConnectionPhase(phase: .connected)
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
                
                if let index = strongSelf.connections.firstIndex(where: { $0.uid == user.uid }) {
                    strongSelf.connections[index].editConnectionPhase(phase: .unconnect)
                }
                
                if let index = strongSelf.followers.firstIndex(where: { $0.uid == user.uid }) {
                    strongSelf.followers[index].editConnectionPhase(phase: .unconnect)
                }

                if let index = strongSelf.following.firstIndex(where: { $0.uid == user.uid }) {
                    strongSelf.following[index].editConnectionPhase(phase: .unconnect)
                }
                
                completion(nil)
            }
        }
    }
}

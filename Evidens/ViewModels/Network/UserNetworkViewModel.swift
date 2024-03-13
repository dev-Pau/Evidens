//
//  UserNetworkViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 8/10/23.
//

import Foundation
import Firebase

/// The viewModel for a UserNetwork.
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
                
                let _ = snapshot.documents.map { UserConnection(uid: $0.documentID, dictionary: $0.data()) }
                
                let uids = snapshot.documents.map { $0.documentID }
                
                UserService.fetchUsers(withUids: uids) { [weak self] users in
                    guard let strongSelf = self else { return }
                    strongSelf.connections = users
                    strongSelf.connectionLoaded = true
                    completion()
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
                    strongSelf.followersLoaded = true
                    completion()
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
                    strongSelf.followingLoaded = true
                    completion()
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
                
                    let newUsers = users
                    strongSelf.followers.append(contentsOf: newUsers)
                    strongSelf.hideFollowerSpinner()
                    completion()
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
                    guard let strongSelf = self else { return }
                    let newUsers = users
                    strongSelf.following.append(contentsOf: newUsers)
                    strongSelf.hideFollowingSpinner()
                    completion()
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

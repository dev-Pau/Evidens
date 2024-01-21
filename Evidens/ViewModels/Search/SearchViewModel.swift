//
//  SearchViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/23.
//

import UIKit
import Firebase

/// The viewModel for a Search.
class SearchViewModel {
    
    var posts = [Post]()
    var postUsers = [User]()
    var cases = [Case]()
    var caseUsers = [User]()
    
    var layoutSubviews: Bool = false
    
    var selectedImage: UIImageView!
    var isEmpty: Bool = false
    var networkFailure: Bool = false
    var currentNotification: Bool = false
    var loaded: Bool = false
    
    var presentingSearchResults: Bool = false
    
    func fetchMainSearchContent(forUser user: User?, completion: @escaping () -> Void) {
        
        guard NetworkMonitor.shared.isConnected, let user = user else {
            networkFailure = true
            loaded = true
            completion()
            return
        }
        
        let group = DispatchGroup()
        
        group.enter()
        PostService.fetchSuggestedPosts(forUser: user) { [weak self] result in
            guard let _ = self else { return }
            switch result {
            case .success(let posts):
                let uids = posts.map { $0.uid }
                UserService.fetchUsers(withUids: uids) { [weak self] users in
                    guard let strongSelf = self else { return }
                    strongSelf.postUsers = users
                    strongSelf.posts = posts
                    group.leave()
                }
                
            case .failure(_):
                group.leave()
                break
            }
        }
        
        group.enter()
        CaseService.fetchSuggestedCases(forUser: user) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let cases):
                strongSelf.cases = cases
                let uids = Array(Set(cases.filter { $0.privacy == .regular }.map { $0.uid } ))
                
                if uids.isEmpty {
                    group.leave()
                } else {
                    UserService.fetchUsers(withUids: uids) { [weak self] users in
                        guard let strongSelf = self else { return }
                        strongSelf.caseUsers = users
                        group.leave()
                    }
                }
            case .failure(_):
                group.leave()
                break
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.isEmpty = strongSelf.posts.isEmpty && strongSelf.cases.isEmpty ? true : false
            strongSelf.loaded = true
            completion()
        }
    }
}

//MARK: - Miscellaneous

extension SearchViewModel {
    
    func hasWeeksPassedSince(forWeeks weeks: Int, timestamp: Timestamp) -> Bool {
        let timestampDate = timestamp.dateValue()
        
        let currentDate = Date()
        
        let weeksAgo = Calendar.current.date(byAdding: .weekOfYear, value: -weeks, to: currentDate)
        
        return timestampDate <= weeksAgo!
    }
}

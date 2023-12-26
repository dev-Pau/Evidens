//
//  PrimaryCasesViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 29/9/23.
//

import UIKit
import Firebase

/// The viewModel for a PrimaryCases.
class PrimaryCasesViewModel {
    
    var isScrollingHorizontally: Bool = false
    
    var scrollIndex = 0
    var isFirstLoad = false
    
    var forYouLastSnapshot: QueryDocumentSnapshot?
    var latestLastSnapshot: QueryDocumentSnapshot?
    
    lazy var forYouCases = [Case]()
    lazy var latestCases = [Case]()
    
    lazy var forYouUsers = [User]()
    lazy var latestUsers = [User]()
    
    var forYouNetwork: Bool = false
    var latestNetwork: Bool = false
    
    var forYouLoaded = false
    var latestLoaded = false
    
    var isFetchingMoreForYou: Bool = false
    var isFetchingMoreLatest: Bool = false
    
    var isFetchingOrDidFetchLatest: Bool = false
    
    func getForYouCases(user: User, completion: @escaping () -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            forYouNetwork = true
            forYouLoaded = true
            completion()
            return
        }
        
        CaseService.fetchCasesWithCategory(query: .you, user: user, lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let snapshot):
                strongSelf.forYouLastSnapshot = snapshot.documents.last
                
                strongSelf.forYouCases = snapshot.documents.map { Case(caseId: $0.documentID, dictionary: $0.data()) }
                
                CaseService.getCaseValuesFor(cases: strongSelf.forYouCases) { [weak self] cases in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.forYouCases = cases
                    let uids = strongSelf.forYouCases.filter { $0.privacy == .regular }.map { $0.uid }
                    let uniqueUids = Array(Set(uids))
                    
                    guard !uniqueUids.isEmpty else {
                        strongSelf.forYouLoaded = true
                        completion()
                        return
                    }
                    
                    UserService.fetchUsers(withUids: uniqueUids) { [weak self] users in
                        guard let strongSelf = self else { return }
                        strongSelf.forYouUsers = users
                        strongSelf.forYouLoaded = true
                        completion()
                    }
                }
                
            case .failure(let error):
                strongSelf.forYouNetwork = error == .network ? true : false
                strongSelf.forYouLoaded = true
                completion()
            }
        }
    }
    
    func getLatestCases(completion: @escaping () -> Void) {
        isFetchingOrDidFetchLatest = true
        
        guard NetworkMonitor.shared.isConnected else {
            latestNetwork = true
            latestLoaded = true
            completion()
            return
        }
        
        CaseService.fetchCasesWithCategory(query: .latest, lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let snapshot):
                strongSelf.latestLastSnapshot = snapshot.documents.last
                
                strongSelf.latestCases = snapshot.documents.map { Case(caseId: $0.documentID, dictionary: $0.data()) }
                
                CaseService.getCaseValuesFor(cases: strongSelf.latestCases) { [weak self] cases in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.latestCases = cases
                    let uids = strongSelf.latestCases.filter { $0.privacy == .regular }.map { $0.uid }
                    let uniqueUids = Array(Set(uids))
                    
                    guard !uniqueUids.isEmpty else {
                        strongSelf.latestLoaded = true
                        completion()
                        return
                    }
                    
                    UserService.fetchUsers(withUids: uniqueUids) { [weak self] users in
                        guard let strongSelf = self else { return }
                        strongSelf.latestUsers = users
                        strongSelf.latestLoaded = true
                        completion()
                    }
                }
                
            case .failure(let error):
                strongSelf.latestNetwork = error == .network ? true : false
                strongSelf.latestLoaded = true
                completion()
            }
        }
    }
    
    func getMoreForYouCases(forUser user: User, completion: @escaping () -> Void) {
        guard !isFetchingMoreForYou, !forYouCases.isEmpty, forYouLoaded else {
            return
        }
        
        showForYouBottomSpinner()
        
        CaseService.fetchCasesWithCategory(query: .you, user: user, lastSnapshot: forYouLastSnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.forYouLastSnapshot = snapshot.documents.last
                let cases = snapshot.documents.map { Case(caseId: $0.documentID, dictionary: $0.data()) }
                
                CaseService.getCaseValuesFor(cases: cases) { [weak self] cases in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.forYouCases.append(contentsOf: cases)
                    let uids = cases.filter { $0.privacy == .regular }.map { $0.uid }
                    let uniqueUids = Array(Set(uids))
                    
                    guard !uniqueUids.isEmpty else {
                        completion()
                        strongSelf.hideForYouBottomSpinner()
                        return
                    }
                    
                    UserService.fetchUsers(withUids: uniqueUids) { [weak self] users in
                        guard let strongSelf = self else { return }
                        strongSelf.forYouUsers.append(contentsOf: users)
                        strongSelf.hideForYouBottomSpinner()
                        completion()
                    }
                }
            case .failure(_):
                strongSelf.hideForYouBottomSpinner()
            }
        }
    }
    
    func getMoreLatestCases(completion: @escaping () -> Void) {
        guard !isFetchingMoreLatest, !latestCases.isEmpty, latestLoaded else {
            return
        }
        
        showLatestBottomSpinner()
        
        CaseService.fetchCasesWithCategory(query: .latest, lastSnapshot: latestLastSnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let snapshot):
                strongSelf.latestLastSnapshot = snapshot.documents.last
                
                let cases = snapshot.documents.map { Case(caseId: $0.documentID, dictionary: $0.data()) }
                
                CaseService.getCaseValuesFor(cases: cases) { [weak self] cases in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.latestCases.append(contentsOf: cases)
                    
                    let uids = cases.filter { $0.privacy == .regular }.map { $0.uid }
                    let uniqueUids = Array(Set(uids))
                    
                    guard !uniqueUids.isEmpty else {
                        strongSelf.hideLatestBottomSpinner()
                        completion()
                        return
                    }
                    
                    UserService.fetchUsers(withUids: uniqueUids) { [weak self] users in
                        guard let strongSelf = self else { return }
                        strongSelf.latestUsers.append(contentsOf: users)
                        strongSelf.hideLatestBottomSpinner()
                        completion()
                    }
                }
                
            case .failure(_):
                strongSelf.hideLatestBottomSpinner()
            }
        }
    }
}

//MARK: - Miscellaneous

extension PrimaryCasesViewModel {
        
    private func showForYouBottomSpinner() {
        isFetchingMoreForYou = true
    }
    
    private func hideForYouBottomSpinner() {
        isFetchingMoreForYou = false
    }
    
    private func showLatestBottomSpinner() {
        isFetchingMoreLatest = true
    }
    
    private func hideLatestBottomSpinner() {
        isFetchingMoreLatest = false
    }
}

//
//  SecondaryCasesViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 30/9/23.
//

import UIKit
import Firebase

/// The viewModel for a SecondaryCases.
class SecondaryCasesViewModel {
    
    var user: User
    
    var users = [User]()
    var cases = [Case]()
    
    private var casesLastSnapshot: QueryDocumentSnapshot?
    
    var networkIssue = false
    var selectedImage: UIImageView!
    
    var currentNotification: Bool = false
    
    var loaded: Bool = false
    
    private var isFetchingMoreCases: Bool = false
    
    init(user: User) {
        self.user = user
    }
    
    func getFirstGroupOfCases(completion: @escaping () -> Void) {
        
        CaseService.fetchUserSearchCases(user: user, lastSnapshot: nil) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let snapshot):
                strongSelf.casesLastSnapshot = snapshot.documents.last
                strongSelf.cases = snapshot.documents.map { Case(caseId: $0.documentID, dictionary: $0.data() )}
                
                let uids = strongSelf.cases.filter { $0.privacy == .regular }.map { $0.uid }
                let uniqueUids = Array(Set(uids))
                
                let group = DispatchGroup()
                
                if !uniqueUids.isEmpty {
                    group.enter()
                    UserService.fetchUsers(withUids: uniqueUids) { [weak self] users in
                        guard let strongSelf = self else { return }
                        strongSelf.users = users
                        group.leave()
                    }
                }
                
                
                group.enter()
                CaseService.getCaseValuesFor(cases: strongSelf.cases) { [weak self] cases in
                    guard let strongSelf = self else { return }
                    strongSelf.cases = cases
                    group.leave()
                }
                
                group.notify(queue: .main) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.cases.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                    strongSelf.loaded = true
                    completion()
                }
                
            case .failure(let error):
                strongSelf.loaded = true
                strongSelf.networkIssue = error == .network ? true : false
                completion()
            }
        }
    }
    
    func getMoreCases(completion: @escaping () -> Void) {
        guard !isFetchingMoreCases, !cases.isEmpty else {
            return
        }
        
        showBottomSpinner()

        CaseService.fetchUserSearchCases(user: user, lastSnapshot: casesLastSnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.casesLastSnapshot = snapshot.documents.last
                let cases = snapshot.documents.map { Case(caseId: $0.documentID, dictionary: $0.data() )}
                
                let uids = strongSelf.cases.filter { $0.privacy == .regular }.map { $0.uid }
                let uniqueUids = Array(Set(uids))
                
                let currentUids = strongSelf.users.map { $0.uid }
                let uidsToFetch = uniqueUids.filter { !currentUids.contains($0) }
                
                let group = DispatchGroup()
                
                if !uidsToFetch.isEmpty {
                    group.enter()
                    UserService.fetchUsers(withUids: uidsToFetch) { [weak self] users in
                        guard let strongSelf = self else { return }
                        strongSelf.users.append(contentsOf: users)
                        group.leave()
                    }
                }
                
                group.enter()
                
                CaseService.getCaseValuesFor(cases: cases) { [weak self] newCases in
                    guard let strongSelf = self else { return }
                    strongSelf.cases.append(contentsOf: newCases)
                    group.leave()
                }
                
                group.notify(queue: .main) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.hideBottomSpinner()
                    completion()
                }
                
            case .failure(_):
                strongSelf.hideBottomSpinner()
            }
        }
    }
}

//MARK: - Miscellaneous

extension SecondaryCasesViewModel {
    
    private func showBottomSpinner() {
        isFetchingMoreCases = true
    }
    
    private func hideBottomSpinner() {
        isFetchingMoreCases = false
    }
}

//MARK: - Delete Operations

extension SecondaryCasesViewModel {
    
    func deleteCase(withId id: String, privacy: CasePrivacy, completion: @escaping(FirestoreError?) -> Void) {
        CaseService.deleteCase(withId: id, privacy: privacy) { [weak self] error in
            guard let _ = self else { return }
            if let error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
}

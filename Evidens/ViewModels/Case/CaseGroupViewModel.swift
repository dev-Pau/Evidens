//
//  File.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/11/23.
//

import Foundation
import Firebase

/// The viewModel for a CaseGroup.
class CaseGroupViewModel {
    
    var cases = [Case]()
    var users = [User]()
    
    private(set) var casesLoaded = false
    private(set) var casesLastSnapshot: QueryDocumentSnapshot?
    
    private(set) var isFetchingMoreCases = false
    
    private let group: CaseGroup
    
    private(set) var filter: CaseFilter = .featured
    
    init(group: CaseGroup) {
        self.group = group
    }
    
    func getTitle() -> String {
        switch group {
            
        case .discipline(let discipline):
            return discipline.name
        case .body(let body, let orientation):
            switch orientation {
            case .front:
                return body.frontName
            case .back:
                return body.backName
            }
        case .speciality(let speciality):
            return speciality.name
        }
    }

    func getCases(completion: @escaping () -> Void) {
        CaseService.fetchCasesWithGroup(group: group, filter: filter, lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.casesLastSnapshot = snapshot.documents.last
                
                let cases = snapshot.documents.map { Case(caseId: $0.documentID, dictionary: $0.data() )}
                
                CaseService.getCaseValuesFor(cases: cases) { [weak self] cases in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.cases = cases
                    let uids = strongSelf.cases.filter { $0.privacy == .regular }.map { $0.uid }
                    let uniqueUids = Array(Set(uids))
                    
                    guard !uniqueUids.isEmpty else {
                        strongSelf.casesLoaded = true
                        completion()
                        return
                    }
                    
                    UserService.fetchUsers(withUids: uniqueUids) { [weak self] users in
                        guard let strongSelf = self else { return }
                        strongSelf.users = users
                        strongSelf.casesLoaded = true
                        completion()
                    }
                }
                
            case .failure(_):
                strongSelf.casesLoaded = true
                completion()
            }
        }
    }
    
    func getMoreCases(completion: @escaping () -> Void) {
        guard !isFetchingMoreCases, casesLoaded, !cases.isEmpty else {
             return
        }
        
        showBottomSpinner()
        
        CaseService.fetchCasesWithGroup(group: group, filter: filter, lastSnapshot: casesLastSnapshot) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.casesLastSnapshot = snapshot.documents.last
                
                let cases = snapshot.documents.map { Case(caseId: $0.documentID, dictionary: $0.data() )}
                
                CaseService.getCaseValuesFor(cases: cases) { [weak self] cases in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.cases.append(contentsOf: cases)
                    let uids = cases.filter { $0.privacy == .regular }.map { $0.uid }
                    let uniqueUids = Array(Set(uids))
                    
                    guard !uniqueUids.isEmpty else {
                        strongSelf.hideBottomSpinner()
                        completion()
                        return
                    }
                    
                    UserService.fetchUsers(withUids: uniqueUids) { [weak self] users in
                        guard let strongSelf = self else { return }
                        strongSelf.users.append(contentsOf: users)
                        strongSelf.hideBottomSpinner()
                        completion()
                    }
                }
                
            case .failure(_):
                strongSelf.hideBottomSpinner()
            }
        }
    }
}

extension CaseGroupViewModel {
    
    private func showBottomSpinner() {
        isFetchingMoreCases = true
    }
    
    private func hideBottomSpinner() {
        isFetchingMoreCases = false
    }
    
    func set(filter: CaseFilter) {
        self.filter = filter
        cases.removeAll()
        users.removeAll()
        casesLoaded = false
        casesLastSnapshot = nil
        isFetchingMoreCases = false
    }
}

//
//  PrimaryCasesViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 29/9/23.
//

import UIKit
import Firebase

class PrimaryCasesViewModel {
    
    var contentSource: CaseDisplay
    
    init(contentSource: CaseDisplay) {
        self.contentSource = contentSource
    }
    
    var users = [User]()
    var cases = [Case]()
    
    var casesLoaded = false
    
    var specialities = [Speciality]()
    
    var speciality: Speciality?
    var discipline: Discipline?

    var casesLastSnapshot: QueryDocumentSnapshot?
    var casesFirstSnapshot: QueryDocumentSnapshot?
    
    var selectedImage: UIImageView!
    
    
    var selectedFilter: CaseFilter = .all
    
    var networkError: Bool = false
    
    var isFetchingMoreCases: Bool = false
    
    func fetchFirstGroupOfCases(completion: @escaping () -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            networkError = true
            casesLoaded = true
            completion()
            return
        }
        
        switch contentSource {
        case .home:

            CaseService.fetchClinicalCases(lastSnapshot: nil) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let snapshot):
                    strongSelf.casesLastSnapshot = snapshot.documents.last
                    strongSelf.casesFirstSnapshot = snapshot.documents.first
                    strongSelf.cases = snapshot.documents.map { Case(caseId: $0.documentID, dictionary: $0.data()) }
                    CaseService.getCaseValuesFor(cases: strongSelf.cases) { [weak self] cases in
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
                    
                case .failure(let error):
                    strongSelf.networkError = error == .network ? true : false

                    strongSelf.casesLoaded = true

                    completion()
                }
            }
        case .explore:
            // No cases are displayed. A collectionView with filtering options is displayed to browse disciplines & user preferences
            casesLoaded = true
            completion()
        case .filter:
            // Cases are shown based on user filtering options
            CaseService.fetchCasesWithDiscipline(lastSnapshot: nil, discipline: discipline, speciality: speciality) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                    
                case .success(let snapshot):
                    strongSelf.casesLastSnapshot = snapshot.documents.last
                    strongSelf.casesFirstSnapshot = snapshot.documents.first
                    strongSelf.cases = snapshot.documents.map { Case(caseId: $0.documentID, dictionary: $0.data()) }
                    
                    CaseService.getCaseValuesFor(cases: strongSelf.cases) { [weak self] cases in
                        guard let strongSelf = self else { return }
                        
                        strongSelf.cases = cases
                        let uids = strongSelf.cases.filter { $0.privacy == .regular }.map { $0.uid }
                        let uniqueUids = Array(Set(uids))
                        
                        guard !uniqueUids.isEmpty else {
                            strongSelf.networkError = false
                            strongSelf.casesLoaded = true
                            completion()
                            return
                        }
                        
                        UserService.fetchUsers(withUids: uniqueUids) { [weak self] users in
                            guard let strongSelf = self else { return }
                            strongSelf.users = users
                            strongSelf.networkError = false
                            strongSelf.casesLoaded = true
                            completion()
                        }
                    }
  
                case .failure(let error):
                    strongSelf.networkError = error == .network ? true : false

                    strongSelf.casesLoaded = true

                    completion()
                }
            }
        }
    }
    
    func getMoreCases(forUser user: User, completion: @escaping () -> Void) {
       
        switch contentSource {
        case .home:
            
            guard !isFetchingMoreCases, !cases.isEmpty, casesLoaded else {
                return
            }

            showBottomSpinner()
            
            CaseService.fetchCasesWithFilter(query: selectedFilter, user: user, lastSnapshot: casesLastSnapshot) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                    
                case .success(let snapshot):
                    strongSelf.casesLastSnapshot = snapshot.documents.last
                    let cases = snapshot.documents.map { Case(caseId: $0.documentID, dictionary: $0.data()) }
                    
                    CaseService.getCaseValuesFor(cases: cases) { [weak self] newCases in
                        strongSelf.cases.append(contentsOf: newCases)
                        print(newCases)
                        let uids = strongSelf.cases.filter { $0.privacy == .regular }.map { $0.uid }
                        let uniqueUids = Array(Set(uids))
                        
                        let currentUids = strongSelf.users.map { $0.uid }
                        let newUids = uniqueUids.filter { !currentUids.contains($0) }
                        
                        guard !newUids.isEmpty else {
                            completion()
                            strongSelf.hideBottomSpinner()
                            return
                        }
                        
                        UserService.fetchUsers(withUids: newUids) { [weak self] users in
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
        case .explore:
            break
        case .filter:
            
            guard !isFetchingMoreCases, !cases.isEmpty, casesLoaded else {
                return
            }

            CaseService.fetchCasesWithDiscipline(lastSnapshot: casesLastSnapshot, discipline: discipline, speciality: speciality) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                    
                case .success(let snapshot):
                    strongSelf.casesLastSnapshot = snapshot.documents.last
                    let cases = snapshot.documents.map { Case(caseId: $0.documentID, dictionary: $0.data()) }
                    
                    CaseService.getCaseValuesFor(cases: cases) { [weak self] newCases in
                        strongSelf.cases.append(contentsOf: newCases)

                        let uids = strongSelf.cases.filter { $0.privacy == .regular }.map { $0.uid }
                        let uniqueUids = Array(Set(uids))
                        
                        let currentUids = strongSelf.users.map { $0.uid }
                        let newUids = uniqueUids.filter { !currentUids.contains($0) }
                        
                        guard !newUids.isEmpty else {
                            strongSelf.hideBottomSpinner()
                            completion()
                            return
                        }
                        
                        UserService.fetchUsers(withUids: newUids) { [weak self] users in
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
    
    func getFilteredCases(forUser user: User, completion: @escaping () -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            networkError = true
            casesLoaded = true
            completion()
            return
        }
        
        casesLoaded = false
        cases.removeAll()
        users.removeAll()
        
        CaseService.fetchCasesWithFilter(query: selectedFilter, user: user, lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.casesFirstSnapshot = snapshot.documents.first
                strongSelf.casesLastSnapshot = snapshot.documents.last
                
                strongSelf.cases = snapshot.documents.map { Case(caseId: $0.documentID, dictionary: $0.data()) }
                CaseService.getCaseValuesFor(cases: strongSelf.cases) { [weak self] cases in
                    guard let strongSelf = self else { return }
                    strongSelf.cases = cases
                    
                    let uids = strongSelf.cases.filter { $0.privacy == .regular }.map { $0.uid }
                    let uniqueUids = Array(Set(uids))

                    
                    guard !uniqueUids.isEmpty else {
                        strongSelf.networkError = false
                        strongSelf.casesLoaded = true
                        completion()
                        return
                    }
                    
                    UserService.fetchUsers(withUids: uniqueUids) { [weak self] users in
                        guard let strongSelf = self else { return }
                        strongSelf.users = users
                        strongSelf.networkError = false
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
}

//MARK: - Miscellaneous

extension PrimaryCasesViewModel {
        
    private func showBottomSpinner() {
        isFetchingMoreCases = true
    }
    
    private func hideBottomSpinner() {
        isFetchingMoreCases = false
    }
}

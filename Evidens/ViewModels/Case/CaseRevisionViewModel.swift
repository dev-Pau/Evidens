//
//  CaseRevisionViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/23.
//

import Foundation

/// The viewModel for a CaseRevision.
class CaseRevisionViewModel {
    
    private(set) var clinicalCase: Case
    
    var user: User?
    var loaded: Bool = false
    
    var revisions = [CaseRevision]()
    
    init(clinicalCase: Case, user: User? = nil) {
        self.clinicalCase = clinicalCase
        self.user = user
    }
    
    func fetchRevisions(completion: @escaping(FirestoreError?) -> Void) {
        CaseService.fetchCaseRevisions(withCaseId: clinicalCase.caseId) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let revisions):
                strongSelf.revisions = revisions.sorted(by: { $0.timestamp.dateValue() < $1.timestamp.dateValue() })
                strongSelf.loaded = true
                completion(nil)
            case .failure(let error):
                strongSelf.loaded = true
                completion(error)
            }
        }
    }
}

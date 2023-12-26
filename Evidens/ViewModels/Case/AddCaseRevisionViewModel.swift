//
//  CaseUpdateViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/7/23.
//

import Foundation

protocol RevisionViewModel {
    var isValid: Bool { get }
}

/// The viewModel for a AddCaseRevision.
struct AddCaseRevisionViewModel: RevisionViewModel {
    
    let clinicalCase: Case
    var title: String?
    var content: String?

    
    var isValid: Bool {
        return title?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && content?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }
    
    init(clinicalCase: Case) {
        self.clinicalCase = clinicalCase
    }
    
    func addRevision(completion: @escaping(FirestoreError?) -> Void) {
        guard let title = title, let content = content else { return }
        
        let revision = CaseRevision(title: title, content: content, kind: .update)

        CaseService.addCaseRevision(withCaseId: clinicalCase.caseId, revision: revision) { error in
            if let error {
                completion(error)
            } else {
                ContentManager.shared.revisionCaseChange(caseId: clinicalCase.caseId)
                completion(nil)
            }
        }
    }
}

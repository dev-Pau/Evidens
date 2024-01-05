//
//  DraftsViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 4/1/24.
//

import Foundation
import Firebase

class DraftsViewModel {
    
    private(set) var cases = [Case]()
    private(set) var caseLoaded: Bool = false
    
    private(set) var caseLastTimestamp: Int64?
    
    private(set) var networkError = false
    private(set) var isFetchingMoreCases: Bool = false
    
    func getCases(completion: @escaping() -> Void) {
        
        DatabaseManager.shared.getDraftCases(lastTimestampValue: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let caseIds):
                
                guard !caseIds.isEmpty else {
                    strongSelf.caseLoaded = true
                    completion()
                    return
                }
                
                CaseService.getPlainCases(withCaseIds: caseIds) { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                        
                    case .success(let cases):
                        strongSelf.cases = cases
                        strongSelf.caseLastTimestamp = strongSelf.cases.last?.timestamp.seconds
                    case .failure(_):
                        break
                    }
                    
                    strongSelf.caseLoaded = true
                    completion()
                }
                
            case .failure(let error):
                strongSelf.caseLoaded = true
                
                if error != .network {
                    completion()
                }
            }
        }
    }
    
    func getMoreCases(completion: @escaping () -> Void) {
        guard !isFetchingMoreCases, !cases.isEmpty, caseLoaded else {
            return
        }
        
        showCaseBottomSpinner()
        
        DatabaseManager.shared.getDraftCases(lastTimestampValue: caseLastTimestamp) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let caseIds):
                guard !caseIds.isEmpty else {
                    strongSelf.hideCaseBottomSpinner()
                    return
                }
                
                CaseService.getPlainCases(withCaseIds: caseIds) { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                        
                    case .success(let cases):
                        strongSelf.cases.append(contentsOf: cases)
                        strongSelf.caseLastTimestamp = strongSelf.cases.last?.timestamp.seconds
                    case .failure(_):
                        break
                    }
                    
                    strongSelf.hideCaseBottomSpinner()
                    completion()
                }
                
            case .failure(_):
                strongSelf.hideCaseBottomSpinner()
            }
        }
    }
}

//MARK: - Miscellaneous

extension DraftsViewModel {
    
    private func showCaseBottomSpinner() {
        isFetchingMoreCases = true
    }
    
    private func hideCaseBottomSpinner() {
        isFetchingMoreCases = false
    }
}

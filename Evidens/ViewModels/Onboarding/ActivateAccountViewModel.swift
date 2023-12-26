//
//  ActivateAccountViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 11/10/23.
//

import Foundation

/// The viewModel for a ActivateAccount.
struct ActivateAccountViewModel {
    
    private let user: User
    
    init(user: User) {
        self.user = user
    }
    
    func deactivateAccountMessage() -> String {
        guard let dDate = user.dDate else { return "" }
        let dateValue = dDate.dateValue()
        
        let dateFormatter = DateFormatter()

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none

        let deactivationDate = dateFormatter.string(from: dateValue)
        
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = 1

        if let nextMonthDate = calendar.date(byAdding: dateComponents, to: dateValue) {
            let deadlineDate = dateFormatter.string(from: nextMonthDate)
            return AppStrings.Opening.deactivateAccountMessage(withDeactivationDate: deactivationDate, withDeadlineDate: deadlineDate)
        }
        
        return ""
    }
    
    func activate(completion: @escaping(FirestoreError?) -> Void) {
        guard let dDate = user.dDate else {
            completion(.unknown)
            return
        }
        
        AuthService.activate(dDate: dDate) { error in
            if let error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
}

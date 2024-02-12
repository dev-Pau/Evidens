//
//  CaseVisibility.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/8/23.
//

import Foundation

/// An enum mapping all the case visibility options.
enum CaseVisibility: Int {
    
    /*
     
     - Regular: The case is visible and accessible to all users.
     - Deleted: The case has been deleted by the user.
     - Pending: The case is pending approval from Evidens.
     - Approve: The case has been approved by Evidens.
     - Hidden: The case is hidden due to the user's account deactivation or deletion.
     - Disabled: The case has been permanently removed by Evidens.
     
     */
    
    case regular, deleted, pending, approve, hidden, disabled

    var content: String {
        switch self {
        case .regular, .deleted, .hidden, .disabled: return ""
        case .pending: return ""
        case .approve: return AppStrings.Content.Draft.reviewCase
        }
    }
}

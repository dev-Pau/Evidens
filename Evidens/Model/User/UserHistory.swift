//
//  History.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/6/23.
//

import Foundation

enum UserHistory {
    case logIn, phase, password
    
    var path: String {
        switch self {
        case .logIn: return AppStrings.User.Changes.login
        case .phase: return AppStrings.User.Changes.phase
        case .password: return AppStrings.User.Changes.pass
        }
    }
}

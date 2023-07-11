//
//  UserKind.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 11/7/23.
//

import Foundation

enum UserKind: Int {
    case professional, student
    
    var title: String {
        switch self {
        case .professional: return AppStrings.Health.Category.professional
        case .student: return AppStrings.Health.Category.student
        }
    }
}

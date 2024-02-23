//
//  UsernameError.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/2/24.
//

import Foundation

enum UsernameError: Error {
    case length, characters, keyword, unique, unknown
    
    var content: String {
        switch self {
            
        case .length: return AppStrings.Error.usernameLength
        case .characters: return AppStrings.Error.usernameCharacters
        case .keyword: return AppStrings.Error.usernameKeyword
        case .unique: return AppStrings.Error.usernameUnique
        case .unknown: return AppStrings.Error.unknown
        }
    }
}

//
//  DatabaseError.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/7/23.
//

import Foundation

/// An enum representing different types of errors that can occur during Realtime Database operations.
enum DatabaseError: Error {
    case network, unknown, exists, empty
    
    var title: String {
        switch self {
        case .network, .unknown, .exists, .empty : return AppStrings.Error.title
        }
    }
    
    var content: String {
        switch self {
        case .network: return AppStrings.Error.network
        case .unknown: return AppStrings.Error.unknown
        case .exists, .empty: return ""
        }
    }
}

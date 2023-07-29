//
//  StorageError.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/7/23.
//

import Foundation

/// An enum representing different types of errors that can occur during Firebase Storage operations.
enum StorageError: Error {
    case network, unknown
    
    var title: String {
        switch self {
        case .network, .unknown : return AppStrings.Error.title
        }
    }
    
    var content: String {
        switch self {
        case .network: return AppStrings.Error.network
        case .unknown: return AppStrings.Error.unknown
        }
    }
}

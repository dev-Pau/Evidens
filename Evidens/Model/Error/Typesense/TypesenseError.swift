//
//  TypesenseError.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/1/24.
//

import Foundation

/// An enum representing different types of errors that can occur during Typsense Error operations.
enum TypesenseError: Error {
    case network, symbols, stopWords, server, empty, unknown
    
    /*
    var title: String {
        switch self {
        case .network, .notFound, .unknown : return AppStrings.Error.title
        }
    }
    
    var content: String {
        switch self {
        case .network: return AppStrings.Error.network
        case .notFound: return AppStrings.Error.notFound
        case .unknown: return AppStrings.Error.unknown
        }
    }
     */
}

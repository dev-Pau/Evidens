//
//  FirestoreError.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/7/23.
//

import Foundation

/// An enum representing different types of errors that can occur during Firebase Firestore operations.
enum FirestoreError: Error {
    case network, notFound, unknown
    
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
}

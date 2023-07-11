//
//  LogInError.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/7/23.
//

import Foundation

enum LogInError: Error {
    case wrongPassword, tooManyRequests, network, unknown
    
    var title: String {
        switch self {
        case .wrongPassword, .tooManyRequests, .network, .unknown: return AppStrings.Error.title
        }
    }
    
    var content: String {
        switch self {
        case .wrongPassword: return AppStrings.Error.password
        case .tooManyRequests: return AppStrings.Error.requests
        case .network: return AppStrings.Error.network
        case .unknown: return AppStrings.Error.unknown
        }
    }
}

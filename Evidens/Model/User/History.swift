//
//  History.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/6/23.
//

import Foundation

enum History {
    case logIn, phase, password
    
    var path: String {
        switch self {
        case .logIn: return "login"
        case .phase: return "phase"
        case .password: return "password"
        }
    }
}

//
//  Legal.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/6/23.
//

import Foundation

enum Legal: Int, CaseIterable {
    case terms, privacy, cookie
    
    var title: String {
        switch self {
        case .terms: return "Terms of Service"
        case .privacy: return "Privacy Policy"
        case .cookie: return "Cookie Policy"
        }
    }
}

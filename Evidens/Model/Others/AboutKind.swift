//
//  AboutUs.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 11/9/23.
//

import Foundation

/// An enum mapping all the about kind options.
enum AboutKind: CaseIterable {
    
    case cooperate, education, network
    
    var title: String {
        switch self {
        case .cooperate: return AppStrings.About.cooperate
        case .education: return AppStrings.About.education
        case .network: return AppStrings.About.network
        }
    }
}

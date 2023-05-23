//
//  CaseType.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 9/7/22.
//

import UIKit

/// The model for a CaseType
struct CaseType {
    var type: String
}

extension CaseType {
    
    /// Gets all the possible case types.
    ///
    /// - Returns:
    /// An array containing all the case types.
    static func allCaseTypes() -> [CaseType] {
        var types: [CaseType] = []
        
        let type1 = "Teaching interest"
        types.append(CaseType(type: type1))
        
        let type2 = "Common presentation"
        types.append(CaseType(type: type2))
        
        let type3 = "Uncommon presentation"
        types.append(CaseType(type: type3))
        
        let type4 = "New disease"
        types.append(CaseType(type: type4))
        
        return types
    }
}

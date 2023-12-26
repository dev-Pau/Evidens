//
//  CaseGuideline.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 8/12/23.
//

import Foundation

/// An enum mapping all the case guidelines options.
enum CaseGuideline: Int, CaseIterable {
    
    case classify, form, stage, submit
    
    var title: String {
        switch self {
            
        case .classify: return AppStrings.Guidelines.Case.classify
        case .form: return AppStrings.Guidelines.Case.form
        case .stage: return AppStrings.Guidelines.Case.stage
        case .submit: return AppStrings.Guidelines.Case.submit
        }
    }
    
    var content: String {
        switch self {
            
        case .classify: return AppStrings.Guidelines.Case.classifyContent
        case .form: return AppStrings.Guidelines.Case.formContent
        case .stage: return AppStrings.Guidelines.Case.stageContent
        case .submit: return AppStrings.Guidelines.Case.submitContent
        }
    }
}

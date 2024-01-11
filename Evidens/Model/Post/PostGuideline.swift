//
//  PostGuideline.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 8/1/24.
//

import Foundation

/// An enum mapping all the post guidelines options.
enum PostGuideline: Int, CaseIterable {
    
    case classify, form, submit
    
    var title: String {
        switch self {
            
        case .classify: return AppStrings.Guidelines.Post.classify
        case .form: return AppStrings.Guidelines.Post.form
        case .submit: return AppStrings.Guidelines.Post.submit
        }
    }
    
    var content: String {
        switch self {
            
        case .classify: return AppStrings.Guidelines.Post.classifyContent
        case .form: return AppStrings.Guidelines.Post.formContent
        case .submit: return AppStrings.Guidelines.Post.submitContent
        }
    }
}

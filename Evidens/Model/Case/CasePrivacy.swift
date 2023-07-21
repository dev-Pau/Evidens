//
//  CasePrivacy.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/7/23.
//

import UIKit

enum CasePrivacy: Int, CaseIterable {
    case regular, anonymous
    
    var title: String {
        switch self {
        case .regular: return AppStrings.Content.Case.Privacy.regularTitle
        case .anonymous: return AppStrings.Content.Case.Privacy.anonymousTitle
        }
    }
    
    var content: String {
        switch self {
        case .regular: return AppStrings.Content.Case.Privacy.regularContent
        case .anonymous: return AppStrings.Content.Case.Privacy.anonymousContent
        }
    }
    
    var image: UIImage {
        switch self {
        case .regular: return UIImage(systemName: AppStrings.Icons.fillEuropeGlobe, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
        case .anonymous: return UIImage(systemName: AppStrings.Icons.eyeGlasses, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
        }
    }
}

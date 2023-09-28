//
//  LoginKind.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 28/9/23.
//

import UIKit

enum LoginKind {
    
    case google, apple
    
    var title: String {
        switch self {
            
        case .google:
            return AppStrings.Opening.googleSignIn
        case .apple:
            return AppStrings.Opening.appleSignIn
        }
    }
    
    var image: UIImage {
        switch self {
            
        case .google: return (UIImage(named: AppStrings.Assets.google)!.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)))
        case .apple: return (UIImage(systemName: AppStrings.Icons.apple)?.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25)))!
        }
    }
}

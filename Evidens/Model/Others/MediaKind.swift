//
//  MediaSource.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 5/2/23.
//

import UIKit

/// The model for a MediaKind.
enum MediaKind: Int, CaseIterable {
    case camera, gallery
    
    var title: String {
        switch self {
        case .camera: return AppStrings.Menu.importCamera
        case .gallery: return AppStrings.Menu.chooseGallery
        }
    }
  
    var image: UIImage {
        switch self {
        case .camera:
            return UIImage(systemName: AppStrings.Icons.camera, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
        case .gallery:
            return UIImage(systemName: AppStrings.Icons.photo, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
        }
    }
}

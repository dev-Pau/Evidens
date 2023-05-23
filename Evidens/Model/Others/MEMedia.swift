//
//  MediaSource.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 5/2/23.
//

import UIKit

/// The model for MEMedia.
struct MEMedia {

    /// An enum mapping the media options for media input.
    enum MediaOptions: String, CaseIterable {
        case camera = "Import from Camera"
        case gallery = "Choose from Gallery"
        
        var mediaOptionsImage: UIImage {
            switch self {
            case .camera:
                return UIImage(systemName: "camera", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
            case .gallery:
                return UIImage(systemName: "photo", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
            }
        }
    }
}

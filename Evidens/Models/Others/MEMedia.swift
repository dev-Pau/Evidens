//
//  MediaSource.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 5/2/23.
//

import UIKit

struct MEMedia {

    enum MediaOptions: String, CaseIterable {
        case camera = "Import from camera"
        case gallery = "Choose from gallery"
        
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

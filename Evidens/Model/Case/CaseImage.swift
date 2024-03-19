//
//  CaseImage.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/9/23.
//

import UIKit

/// The model for a CaseImage.
struct CaseImage {
    let image: UIImage

    var containsFaces: Bool
    var isRevealed: Bool
    
    init(image: UIImage, containsFaces: Bool = false) {
        self.image = image
        self.containsFaces = containsFaces
        self.isRevealed = !containsFaces
    }
    
    func getImage() -> UIImage {
        return image
    }
}

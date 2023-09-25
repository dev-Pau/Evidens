//
//  CaseImage.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/9/23.
//

import UIKit

struct CaseImage {
    let image: UIImage
    var faceImage: UIImage?
    
    var containsFaces: Bool
    var isRevealed: Bool
    
    init(image: UIImage, faceImage: UIImage?) {
        self.image = image
        
        if let faceImage {
            self.faceImage = faceImage
            self.containsFaces = true
            self.isRevealed = false
        } else {
            self.containsFaces = false
            self.isRevealed = true
        }
    }
    
    func getImage() -> UIImage {
        if let faceImage {
            return faceImage
        } else {
            return image
        }
    }
}

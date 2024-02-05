//
//  HomeImageViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/23.
//

import UIKit

/// The viewModel for a HomeImage.
struct HomeImageViewModel {
    
    var images: [UIImage]
    var index: Int
    
    var pageImages: [ZoomImageView] = []
    
    var buttonsHidden: Bool = false
    var buttonsAnimating: Bool = false
    
    var isScrollingHorizontal: Bool = false
    var isZoom: Bool = false
    
    init(images: [UIImage], index: Int) {
        self.images = images
        self.index = index
    }
}

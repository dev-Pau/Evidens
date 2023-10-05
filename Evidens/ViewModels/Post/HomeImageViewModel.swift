//
//  HomeImageViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/23.
//

import UIKit

struct HomeImageViewModel {
    
    var postImage: [UIImage]
    var imageCount: Int
    var index: Int
    
    var statusBarIsHidden: Bool = false
    
    init(image: [UIImage], imageCount: Int, index: Int) {
        self.postImage = image
        self.imageCount = imageCount
        self.index = index
    }
}

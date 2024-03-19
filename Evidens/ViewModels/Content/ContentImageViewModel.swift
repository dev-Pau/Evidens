//
//  ContentImageViewmodel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/3/24.
//

import UIKit

struct ContentImageViewModel {
    
    var image: UIImage
    let navVC: UINavigationController?

    var buttonsHidden: Bool = false
    var buttonsAnimating: Bool = false
    
    var isScrollingHorizontal: Bool = false
    var isZoom: Bool = false
    
    init(image: UIImage, navVC: UINavigationController?) {
        self.image = image
        self.navVC = navVC
    }
}

//
//  MEPostImage.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/6/22.
//

import UIKit

class MEPostImage: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    init(image: UIImage) {
        super.init(frame: .zero)
        self.image = image
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        contentMode = .scaleAspectFill
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    

    
    
}

//
//  BaseGuidelineImageCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 8/12/23.
//

import UIKit

class BaseGuidelineImageCell: UICollectionViewCell {
    
    private let image: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = K.Colors.dimPrimaryColor
        addSubviews(image)
        
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            image.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            image.centerXAnchor.constraint(equalTo: centerXAnchor),
            image.widthAnchor.constraint(equalToConstant: frame.height - 20)
        ])
    }
    
    func set(image: String) {
        self.image.image = UIImage(named: image)
    }
}

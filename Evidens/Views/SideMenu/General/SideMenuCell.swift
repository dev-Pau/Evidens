//
//  SideMenuCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/9/22.
//

import UIKit

class SideMenuCell: UICollectionViewCell {
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 18.0, scaleStyle: .title2, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = .label
        return label
    }()
    
    private let image: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .center
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews(label, image)
        
        let size: CGFloat = UIDevice.isPad ? 30 : 25
        
        NSLayoutConstraint.activate([
            image.centerYAnchor.constraint(equalTo: centerYAnchor),
            image.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            image.heightAnchor.constraint(equalToConstant: size),
            image.widthAnchor.constraint(equalToConstant: size),
            
            label.centerYAnchor.constraint(equalTo: image.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }
    
    func set(option: SideMenu) {
        let size: CGFloat = UIDevice.isPad ? 30 : 25
        
        switch option {
            
        case .profile, .bookmark, .draft:
            self.image.image = option.image.scalePreservingAspectRatio(targetSize: CGSize(width: size, height: size)).withTintColor(option.color)
            self.image.backgroundColor = .systemBackground
            self.image.layer.cornerRadius = 0
        case .create:
            self.image.image = option.image.scalePreservingAspectRatio(targetSize: CGSize(width: size / 1.5, height: size / 1.5)).withTintColor(option.color)
            self.image.backgroundColor = K.Colors.primaryColor
            self.image.layer.cornerRadius = size / 2
        }
        
        label.text = option.title
        label.textColor = option == .create ? K.Colors.primaryColor : .label
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

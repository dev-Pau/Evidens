//
//  SideMenuCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/9/22.
//

import UIKit

class SideMenuCell: UICollectionViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()
    
    private let titleImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews(titleLabel, titleImage)
        
        NSLayoutConstraint.activate([
            titleImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleImage.heightAnchor.constraint(equalToConstant: 20),
            titleImage.widthAnchor.constraint(equalToConstant: 20),
            
            titleLabel.centerYAnchor.constraint(equalTo: titleImage.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: titleImage.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }
    
    func set(title: String, image: String) {
        titleLabel.text = title
        titleImage.image = UIImage(systemName: image, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.black)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

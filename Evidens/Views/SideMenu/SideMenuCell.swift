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
        label.textColor = .label
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
            titleImage.heightAnchor.constraint(equalToConstant: 25),
            titleImage.widthAnchor.constraint(equalToConstant: 25),
            
            titleLabel.centerYAnchor.constraint(equalTo: titleImage.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: titleImage.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }
    
    func set(title: String, image: String) {
        titleLabel.text = title
        if title == "Jobs" {
            titleImage.image = UIImage(systemName: image)?.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25)).withTintColor(.label).withRenderingMode(.alwaysOriginal)
        } else {
            titleImage.image = UIImage(named: image)?.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25)).withTintColor(.label).withRenderingMode(.alwaysOriginal)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  PlaceholderCaseImageCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/8/23.
//

import UIKit


class PlaceholderCaseImageCell: UICollectionViewCell {
    
    private let placeholderImage: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = false
        iv.image = UIImage(named: AppStrings.Assets.image)?.withTintColor(primaryColor)
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
        layer.cornerRadius = 10
        backgroundColor = .quaternarySystemFill
        addSubviews(placeholderImage)

        NSLayoutConstraint.activate([
            placeholderImage.centerXAnchor.constraint(equalTo: centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            placeholderImage.heightAnchor.constraint(equalToConstant: 50),
            placeholderImage.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
}

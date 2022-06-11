//
//  PostMenuCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 11/6/22.
//

import UIKit


class PostMenuCell: UICollectionViewCell {
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? grayColor : .white
            postTypeLabel.textColor = isHighlighted ? .white : blackColor
        }
    }
    
    private let padding: CGFloat = 10
    
    private let postTypeImage: UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let postTypeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = blackColor
        return label
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        addSubview(postTypeImage)
        addSubview(postTypeLabel)
        
        NSLayoutConstraint.activate([
            postTypeImage.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            postTypeImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            postTypeImage.widthAnchor.constraint(equalToConstant: 30),
            postTypeImage.heightAnchor.constraint(equalToConstant: 30),
            
            postTypeLabel.centerYAnchor.constraint(equalTo: postTypeImage.centerYAnchor),
            postTypeLabel.leadingAnchor.constraint(equalTo: postTypeImage.trailingAnchor, constant: padding),
            postTypeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            postTypeLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        postTypeImage.layer.cornerRadius = postTypeImage.frame.size.height / 2
    }
    
    func set(withText text: String, withImage image: UIImage) {
        postTypeImage.image = image
        postTypeLabel.text = text
    }
}

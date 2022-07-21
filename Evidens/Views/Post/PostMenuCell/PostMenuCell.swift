//
//  PostMenuCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 11/6/22.
//

import UIKit


class PostMenuCell: UICollectionViewCell {
    
    private let padding: CGFloat = 10
    
    private let postTypeImage: UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    lazy var postTyeButton: UIButton = {
        let button = UIButton()
        button.configuration = .plain()
        button.configuration?.baseForegroundColor = .black

        button.configuration?.cornerStyle = .capsule
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    
    private let postTypeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
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
        addSubview(postTyeButton)
        addSubview(postTypeLabel)
        
        NSLayoutConstraint.activate([
            postTyeButton.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            postTyeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            postTyeButton.widthAnchor.constraint(equalToConstant: 30),
            postTyeButton.heightAnchor.constraint(equalToConstant: 30),
            
            postTypeLabel.centerYAnchor.constraint(equalTo: postTyeButton.centerYAnchor),
            postTypeLabel.leadingAnchor.constraint(equalTo: postTyeButton.trailingAnchor, constant: padding),
            postTypeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            postTypeLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        postTypeImage.layer.cornerRadius = postTypeImage.frame.size.height / 2
    }
    
    func set(withText text: String, withImage image: UIImage) {
        postTyeButton.configuration?.image = image
        postTypeLabel.text = text
        if text == "Delete" || text == "Report this post" {
            postTypeLabel.textColor = .red
            postTypeLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        }
    }
}

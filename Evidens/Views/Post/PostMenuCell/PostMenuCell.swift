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
    
    private lazy var postTyeButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.baseForegroundColor = grayColor
        button.configuration?.baseBackgroundColor = lightGrayColor

        button.configuration?.cornerStyle = .capsule
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
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
    }
}

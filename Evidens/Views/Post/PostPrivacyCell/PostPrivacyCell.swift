//
//  PostPrivacyMenu.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/6/22.
//

import UIKit


class PostPrivacyCell: UICollectionViewCell {
    
    
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
        button.configuration?.baseBackgroundColor = .white

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
    
    private let postTypeSubLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = grayColor
        return label
    }()
    
    let selectedOptionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        
        button.configuration?.baseForegroundColor = primaryColor

        button.configuration?.cornerStyle = .capsule

        return button
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {

        let stack = UIStackView(arrangedSubviews: [postTypeLabel, postTypeSubLabel])
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = 5
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubviews(postTyeButton, selectedOptionButton, stack)
        
        NSLayoutConstraint.activate([
            postTyeButton.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            postTyeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            postTyeButton.widthAnchor.constraint(equalToConstant: 30),
            postTyeButton.heightAnchor.constraint(equalToConstant: 30),
            
            selectedOptionButton.centerYAnchor.constraint(equalTo: postTyeButton.centerYAnchor),
            selectedOptionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            selectedOptionButton.heightAnchor.constraint(equalToConstant: 15),
            selectedOptionButton.widthAnchor.constraint(equalToConstant: 15),
            
            stack.centerYAnchor.constraint(equalTo: postTyeButton.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: postTyeButton.trailingAnchor, constant: padding),
            stack.trailingAnchor.constraint(equalTo: selectedOptionButton.leadingAnchor, constant: padding),
            stack.heightAnchor.constraint(equalToConstant: 35)
            
        ])
        
        postTypeImage.layer.cornerRadius = postTypeImage.frame.size.height / 2
    }
    
    func set(withText text: String, witSubtitle subtitle: String, withImage image: UIImage) {
        postTyeButton.configuration?.image = image
        postTypeLabel.text = text
        postTypeSubLabel.text = subtitle
    }
}
//
//  PostAttachementMenuCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/6/22.
//

import UIKit


class PostAttachementCell: UICollectionViewCell {
    
    private let padding: CGFloat = 10
    
    private lazy var postTyeButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.baseBackgroundColor = lightColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    private let postTypeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
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
        
        backgroundColor = .white
        
        NSLayoutConstraint.activate([
            postTyeButton.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            postTyeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            postTyeButton.widthAnchor.constraint(equalToConstant: 35),
            postTyeButton.heightAnchor.constraint(equalToConstant: 35),
            
            postTypeLabel.centerYAnchor.constraint(equalTo: postTyeButton.centerYAnchor),
            postTypeLabel.leadingAnchor.constraint(equalTo: postTyeButton.trailingAnchor, constant: 2 * padding),
            postTypeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            postTypeLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func set(withText text: String, withImage image: UIImage) {
        postTyeButton.configuration?.image = image.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal).withTintColor(grayColor)

        postTypeLabel.text = text
    }
}

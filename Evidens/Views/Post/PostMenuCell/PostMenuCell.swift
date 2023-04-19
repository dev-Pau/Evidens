//
//  PostMenuCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 11/6/22.
//

import UIKit


class PostMenuCell: UICollectionViewCell {
    
    private let padding: CGFloat = 15

    lazy var postTyeButton: UIButton = {
        let button = UIButton()
        button.configuration = .plain()
        button.configuration?.cornerStyle = .capsule
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    private let postTypeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            postTyeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            postTyeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            postTyeButton.widthAnchor.constraint(equalToConstant: 35),
            postTyeButton.heightAnchor.constraint(equalToConstant: 35),
            
            postTypeLabel.centerYAnchor.constraint(equalTo: postTyeButton.centerYAnchor),
            postTypeLabel.leadingAnchor.constraint(equalTo: postTyeButton.trailingAnchor, constant: padding),
            postTypeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            //postTypeLabel.heightAnchor.constraint(equalToConstant: 30)
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: postTypeLabel.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4)
        ])
    }
    
    func set(withText text: String, withImage image: UIImage) {
        postTyeButton.configuration?.image = image.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal).withTintColor(.label)
        postTypeLabel.text = text
        
        /*
        
        if text == "Delete" || text == "Report this Post" || text == "Delete notification" || text == "Report this Case" || text == "Delete conversation"  {
            postTypeLabel.textColor = .systemRed
            postTypeLabel.font = .systemFont(ofSize: 16, weight: .semibold)
            postTyeButton.configuration?.image = image.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal).withTintColor(.systemRed)
        } else {
            postTypeLabel.textColor = primaryColor
            postTypeLabel.font = .systemFont(ofSize: 16, weight: .medium)
        }
         */
    }
}

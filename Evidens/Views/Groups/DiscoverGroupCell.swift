//
//  GroupManagerHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/11/22.
//

import UIKit

class DiscoverGroupCell: UICollectionViewCell {
    
    private let exploreImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(systemName: "safari", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withRenderingMode(.alwaysOriginal).withTintColor(.black)
        return iv
    }()
    
    private let exploreTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Discover groups"
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    private let exploreDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Find trusted communities that other members created"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = grayColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private let exploreGroupsButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.baseBackgroundColor = primaryColor
        
        var container = AttributeContainer()
        container.font = UIFont.boldSystemFont(ofSize: 15)
        button.configuration?.attributedTitle = AttributedString("Discover", attributes: container)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = lightColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let groupSizeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
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
        backgroundColor = .white
        addSubviews(exploreImage, exploreTitleLabel, exploreDescriptionLabel, exploreGroupsButton, separatorView)
        
        NSLayoutConstraint.activate([
            exploreImage.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            exploreImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            exploreImage.heightAnchor.constraint(equalToConstant: 30),
            exploreImage.widthAnchor.constraint(equalToConstant: 30),
            
            exploreTitleLabel.topAnchor.constraint(equalTo: exploreImage.topAnchor),
            exploreTitleLabel.leadingAnchor.constraint(equalTo: exploreImage.trailingAnchor, constant: 10),
            exploreTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            exploreDescriptionLabel.topAnchor.constraint(equalTo: exploreTitleLabel.bottomAnchor),
            exploreDescriptionLabel.leadingAnchor.constraint(equalTo: exploreTitleLabel.leadingAnchor),
            exploreDescriptionLabel.trailingAnchor.constraint(equalTo: exploreTitleLabel.trailingAnchor),
            
            exploreGroupsButton.topAnchor.constraint(equalTo: exploreDescriptionLabel.bottomAnchor, constant: 10),
            exploreGroupsButton.leadingAnchor.constraint(equalTo: exploreDescriptionLabel.leadingAnchor),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        exploreImage.layer.cornerRadius = 30 / 2
        
    }
}

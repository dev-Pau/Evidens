//
//  SideMenuHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/9/22.
//

import UIKit

protocol SideMenuViewDelegate: AnyObject {
    func didTapProfile()
}

class SideMenuView: UIView {
    
    weak var delegate: SideMenuViewDelegate?
    
    private lazy var userImage = ProfileImageView(frame: .zero)
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .headline)
        let heavyFontDescriptor = fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.traits: [
                UIFontDescriptor.TraitKey.weight: UIFont.Weight.bold.rawValue
            ]
        ])
        
        label.font = UIFont(descriptor: heavyFontDescriptor, size: 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .label
        label.textAlignment = .left
        return label
    }()
    
    private let profileLabel: UILabel = {
        let label = UILabel()
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .subheadline)
        let heavyFontDescriptor = fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.traits: [
                UIFontDescriptor.TraitKey.weight: UIFont.Weight.medium.rawValue
            ]
        ])
        
        label.font = UIFont(descriptor: heavyFontDescriptor, size: 0)
        label.text = AppStrings.Profile.view
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.textAlignment = .left
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
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleHeaderTap)))
        
        addSubviews(userImage, nameLabel, profileLabel, separatorView)
        NSLayoutConstraint.activate([

            userImage.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            userImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            userImage.heightAnchor.constraint(equalToConstant: 45),
            userImage.widthAnchor.constraint(equalToConstant: 45),
            
            nameLabel.topAnchor.constraint(equalTo: userImage.bottomAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: userImage.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            profileLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            profileLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            profileLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            profileLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: userImage.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4)
        ])

        userImage.layer.cornerRadius = 45 / 2
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        if let imageString = UserDefaults.standard.value(forKey: "profileUrl") as? String, imageString != "" {
            userImage.sd_setImage(with: URL(string: imageString))
        }
        
        if let name = UserDefaults.standard.value(forKey: "name") as? String {
            nameLabel.text = name
        }
    }
    
    @objc func handleHeaderTap() {
        delegate?.didTapProfile()
    }
}

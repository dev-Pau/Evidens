//
//  GroupManagerCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 8/11/22.
//

import UIKit

protocol GroupManagerCellDelegate: AnyObject {
    func didTapToogleHideDiscover(isExpanding: Bool)
}

class GroupManagerCell: UICollectionViewCell {
    
    private var discoverMenuExpanded: Bool = true
    
    weak var delegate: GroupManagerCellDelegate?
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "user.profile")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let groupNameButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.baseForegroundColor = .black
        button.configuration?.image = UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).scalePreservingAspectRatio(targetSize: CGSize(width: 18, height: 18))
        button.configuration?.imagePadding = 5
        button.configuration?.imagePlacement = .trailing
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 16, weight: .medium)
        button.configuration?.attributedTitle = AttributedString("Veterinary medicine", attributes: container)

        button.contentHorizontalAlignment = .left
        button.translatesAutoresizingMaskIntoConstraints = false
        
        
        return button
    }()
    
    private lazy var discoverButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.baseForegroundColor = grayColor
        button.configuration?.baseBackgroundColor = lightColor
        button.configuration?.image = UIImage(systemName: "chevron.up", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withRenderingMode(.alwaysOriginal).withTintColor(grayColor).scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15))
        button.addTarget(self, action: #selector(didTapToogleHide), for: .touchUpInside)
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
        backgroundColor = .white
        addSubviews(profileImageView, groupNameButton, discoverButton)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            
            groupNameButton.topAnchor.constraint(equalTo: topAnchor),
            groupNameButton.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor),
            groupNameButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
            
            discoverButton.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            discoverButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            discoverButton.widthAnchor.constraint(equalToConstant: 20),
            discoverButton.heightAnchor.constraint(equalToConstant: 20)
            
            
        ])
        
        profileImageView.layer.cornerRadius = 40 / 2
        
        discoverButton.configurationUpdateHandler = { [unowned self] button in
            var config = button.configuration
            
            var container = AttributeContainer()
            container.font = .systemFont(ofSize: 14, weight: .bold)
            config?.image = discoverMenuExpanded ? UIImage(systemName: "chevron.up", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withRenderingMode(.alwaysOriginal).withTintColor(grayColor).scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)) : UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withRenderingMode(.alwaysOriginal).withTintColor(grayColor).scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15))
            button.configuration = config
        }
    }
    
    func set(user: User) {
        profileImageView.sd_setImage(with: URL(string: user.profileImageUrl!))
    }
    
    @objc func didTapToogleHide() {
        discoverMenuExpanded.toggle()
        delegate?.didTapToogleHideDiscover(isExpanding: discoverMenuExpanded)
        discoverButton.setNeedsUpdateConfiguration()
    }
}

//
//  SearchBarContainerView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/9/22.
//

import UIKit

class SearchBarContainerView: UIView {

    let searchBar: UISearchBar

    init(customSearchBar: UISearchBar) {
        searchBar = customSearchBar
        super.init(frame: CGRect.zero)

        addSubview(searchBar)
    }

    override convenience init(frame: CGRect) {
        self.init(customSearchBar: UISearchBar())
        self.frame = frame
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        searchBar.frame = bounds
    }
    
    func setCornerRadius() {

    }
}

class MENavigationBarTitleView: UIView {
    
    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(fullName: String, category: String) {
        fullNameLabel.text = fullName
        categoryLabel.text = category
        super.init(frame: CGRect.zero)
        addSubviews(fullNameLabel, categoryLabel)
    }
    
    override convenience init(frame: CGRect) {
        self.init(frame: frame)
        self.frame = frame
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            fullNameLabel.topAnchor.constraint(equalTo: topAnchor),
            fullNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            fullNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            categoryLabel.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor),
            categoryLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            categoryLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}

class MENavigationBarChatView: UIView {
    
    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.image = UIImage(named: "user.profile")
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    init(user: User) {
        fullNameLabel.text = user.firstName!
        if let imageUrl = user.profileImageUrl, imageUrl != "" {
            profileImageView.sd_setImage(with: URL(string: imageUrl))
        }
        
        super.init(frame: CGRect.zero)
        addSubviews(fullNameLabel, profileImageView)
    }
    
    override convenience init(frame: CGRect) {
        self.init(frame: frame)
        self.frame = frame
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            
            fullNameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            fullNameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            profileImageView.trailingAnchor.constraint(equalTo: fullNameLabel.leadingAnchor, constant: -10),
            profileImageView.heightAnchor.constraint(equalToConstant: 35),
            profileImageView.widthAnchor.constraint(equalToConstant: 35),
        ])
        
        profileImageView.layer.cornerRadius = 35 / 2
    }
}

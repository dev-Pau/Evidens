//
//  UserProfileHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/5/22.
//

import UIKit

class UserProfileHeader: UITableViewHeaderFooterView {
    
    //MARK: - Properties
    
    var viewModel: ProfileHeaderViewModel? {
        didSet {
            configure()
        }
    }
    
    private lazy var bannerImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(named: "banner")
        return iv
    }()
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "person.fill")
        iv.layer.borderWidth = 3
        iv.layer.borderColor = UIColor(rgb: 0xFFFFFF).cgColor
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .bold)
        label.numberOfLines = 1
        label.textColor = blackColor
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .white
        
        addSubview(bannerImageView)
        bannerImageView.setDimensions(height: 120, width: UIScreen.main.bounds.width)
        bannerImageView.anchor(top: topAnchor, left: leftAnchor)
        
        addSubview(profileImageView)
        profileImageView.setDimensions(height: 120, width: 120)
        profileImageView.layer.cornerRadius = 120/2
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 60, paddingLeft: 10)
        
        addSubview(nameLabel)
        nameLabel.anchor(top: profileImageView.bottomAnchor, left: profileImageView.leftAnchor, paddingTop: 10)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    func configure() {
        guard let viewModel = viewModel else { return }
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        nameLabel.text = "\(viewModel.firstName ) \(viewModel.lastName)"
    }
    
    //MARK: - Lifecycle
    
    //MARK: - Actions
    
    //MARK: - API
}

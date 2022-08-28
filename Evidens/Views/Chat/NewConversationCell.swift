//
//  NewConversationCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/2/22.
//
import UIKit
import SDWebImage


class NewConversationCell: UITableViewCell {
    
    //MARK: - Properties
    
    var viewModel: UserCellViewModel? {
        didSet {
            configure()
        }
    }
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    

    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(profileImageView)
        contentView.addSubview(usernameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profileImageView.anchor(top: contentView.topAnchor,
                                left: contentView.leftAnchor,
                                paddingTop: 10,
                                paddingLeft: 10,
                                width: 50,
                                height: 50)
        
        usernameLabel.anchor(top: profileImageView.topAnchor,
                             left: profileImageView.rightAnchor,
                             bottom: profileImageView.bottomAnchor,
                             paddingLeft: 10,
                             width: contentView.bounds.width - 20 - profileImageView.bounds.width)
    }
    
    
    
    //MARK: - Helpers
    
    public func configure() {
        guard let viewModel = viewModel else { return }
        usernameLabel.text = viewModel.fullName
        profileImageView.sd_setImage(with: viewModel.userProfileImageUrl)

    }
    
    //MARK: - Actions
}

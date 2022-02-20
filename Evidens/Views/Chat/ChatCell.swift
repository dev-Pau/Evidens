//
//  ChatCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/2/22.
//

import UIKit
import SDWebImage


class ChatCell: UITableViewCell {
    
    //MARK: - Properties
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    private let userMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(profileImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(userMessageLabel)
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
                                width: 100,
                                height: 100)
        
        usernameLabel.anchor(top: profileImageView.topAnchor,
                             left: profileImageView.rightAnchor,
                             paddingLeft: 10,
                             width: contentView.bounds.width - 20 - profileImageView.bounds.width,
                             height: (contentView.bounds.height-20)/2)
        
        userMessageLabel.anchor(top: usernameLabel.bottomAnchor,
                                left: profileImageView.rightAnchor,
                                paddingTop: 10, paddingLeft: 10,
                                width: contentView.bounds.width - 20 - profileImageView.bounds.width,
                                height: (contentView.bounds.height - 20)/2)
    }
    
    
    
    //MARK: - Helpers
    
    public func configure(with model: Conversation) {
        self.userMessageLabel.text = model.latestMessage.text
        self.usernameLabel.text = model.name

        let path = "/profile_images/\(model.otherUserUid)"
        ImageUploader.downloadImageURL(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):
                
                DispatchQueue.main.async {
                    self?.profileImageView.sd_setImage(with: url, completed: nil)
                }
                
            case.failure(let error):
                print("failed to get image url: \(error)")
            }
        })
       
    }
    
    //MARK: - Actions
}

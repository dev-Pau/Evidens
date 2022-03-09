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
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let userMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(profileImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(userMessageLabel)
        contentView.addSubview(dateLabel)
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
                                width: 70,
                                height: 70)
        
        usernameLabel.anchor(top: profileImageView.topAnchor,
                             left: profileImageView.rightAnchor,
                             paddingLeft: 10,
                             width: contentView.bounds.width - 20 - profileImageView.bounds.width)
                             
        
        userMessageLabel.anchor(top: usernameLabel.bottomAnchor,
                                left: profileImageView.rightAnchor,
                                paddingTop: 10,
                                paddingLeft: 10,
                                width: contentView.bounds.width - 20 - profileImageView.bounds.width,
                                height: contentView.bounds.height - 10 - usernameLabel.bounds.height - 10)
        
        dateLabel.anchor(top: profileImageView.topAnchor,
                         right: contentView.rightAnchor,
                         paddingRight: 10)
    }
    
    
    
    //MARK: - Helpers
    
    public func configure(with model: Conversation) {
        
        let message = model.latestMessage.text
        if message.contains("https://firebasestorage.googleapis.com") {
            //Is a photo or video
            if message.contains("message_images") {
                userMessageLabel.text = "Photo"
            } else {
                userMessageLabel.text = "Video"
            }
        } else {
            //It is a normal message
            userMessageLabel.text = model.latestMessage.text
        }
        
        usernameLabel.text = model.name
        
        let dateString = model.latestMessage.date.replacingOccurrences(of: " at", with: "").replacingOccurrences(of: " CET", with: "")
        
        let addedDateFormatter = DateFormatter()
        addedDateFormatter.dateFormat = "d MMM yyyy HH:mm:ss"
        addedDateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        if let addedDate = addedDateFormatter.date(from: dateString) {
            dateLabel.text = addedDate.formatRelativeString()
        }
        
        let path = "/profile_images/\(model.otherUserUid)"
        StorageManager.downloadImageURL(for: path, completion: { [weak self] result in
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

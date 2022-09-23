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
        imageView.layer.cornerRadius = 50/2
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .clear
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = grayColor
        label.numberOfLines = 2
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = grayColor
        label.textAlignment = .right
        label.numberOfLines = 0
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubviews(profileImageView, usernameLabel, userMessageLabel, dateLabel)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
        
            usernameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            usernameLabel.trailingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            
            userMessageLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor),
            userMessageLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            usernameLabel.trailingAnchor.constraint(equalTo: usernameLabel.trailingAnchor)
            
        ])
    }
    
    
    
    //MARK: - Helpers
    
    public func configure(with model: Conversation) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        //if model.latestMessage.
        
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
        
        if model.latestMessage.senderUid == uid {
            userMessageLabel.text = "You: \(userMessageLabel.text ?? "")"
        }
        
        usernameLabel.text = model.name
        
        dateLabel.text = model.latestMessage.date.replacingOccurrences(of: " at", with: "").replacingOccurrences(of: " CEST", with: "")
        let dateString = model.latestMessage.date.replacingOccurrences(of: " at", with: "").replacingOccurrences(of: " CEST", with: "")
        
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

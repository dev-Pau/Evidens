//
//  NotificationCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/11/21.
//

import Foundation
import UIKit

class NotificationCell: UITableViewCell {
    
    //MARK: - Properties
    
    private let notificationTypeImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.tintColor = .red
        iv.image = UIImage(systemName: "heart.fill")
        return iv
    }()
    
    private let notificationTypeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "liked your post"
        return label
    }()
    
    private let notificationTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "comment of user"
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.image = UIImage(systemName: "person.circle")
        let tap = UIGestureRecognizer(target: self, action: #selector(didTapProfile))
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(tap)
        return iv
    }()
    
    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "Evidens"
        return label
    }()
    
    private let followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.layer.cornerRadius = 3
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(didTapFollowButton), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        addSubview(notificationTypeImageView)
        notificationTypeImageView.setDimensions(height: 24, width: 24)
        notificationTypeImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        
        addSubview(profileImageView)
        profileImageView.setDimensions(height: 40, width: 40)
        profileImageView.layer.cornerRadius = 40/2
        profileImageView.anchor(top: notificationTypeImageView.topAnchor, left: notificationTypeImageView.rightAnchor, paddingLeft: 5)
        
        addSubview(fullNameLabel)
        fullNameLabel.anchor(top: profileImageView.bottomAnchor, left: profileImageView.leftAnchor, paddingTop: 5)
        
        addSubview(notificationTypeLabel)
        notificationTypeLabel.centerY(inView: fullNameLabel, leftAnchor: fullNameLabel.rightAnchor, paddingLeft: 5)
        
        addSubview(notificationTextLabel)
        notificationTextLabel.anchor(top: fullNameLabel.bottomAnchor, left: fullNameLabel.leftAnchor, paddingTop: 5)
        
        addSubview(followButton)
        followButton.centerY(inView: notificationTypeImageView)
        followButton.anchor(right: rightAnchor, paddingRight: 12, width: 100, height: 32)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Actions
    @objc func didTapFollowButton() {
        
    }
    
    @objc func didTapProfile() {
        
    }
}

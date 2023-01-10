//
//  UserProfileNoCommentsCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 8/8/22.
//

import UIKit

class UserProfileNoCommentsCell: UICollectionViewCell {
    
    private var postTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var postTextSubLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        backgroundColor = .systemBackground
        
        addSubviews(postTextLabel, postTextSubLabel)
        
        NSLayoutConstraint.activate([
            postTextLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            postTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            postTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            postTextSubLabel.topAnchor.constraint(equalTo: postTextLabel.bottomAnchor, constant: 5),
            postTextSubLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            postTextSubLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            postTextSubLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])
        
    }
    
    func configure(user: User) {
        if user.isCurrentUser {
            postTextLabel.text = "You havn't commented lately"
            postTextSubLabel.text = "You will be able to see your comments here."
        } else {
            postTextLabel.text = "\(user.firstName!) hasn't commented lately."
            postTextSubLabel.text = "You will be able to see their comments here."
        }
    }
}



//
//  ProfileCommentCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/8/22.
//

import UIKit

class UserProfileCommentCell: UICollectionViewCell {
    
    private var caseTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var commentTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var commentUserLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 3
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var commentHeightView: UIView = {
        let view = UIView()
        view.backgroundColor = primaryColor
        view.layer.cornerRadius = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = lightGrayColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        backgroundColor = .white
        
        addSubviews(caseTitleLabel, commentTextLabel, commentUserLabel, separatorView, commentHeightView)
        
        NSLayoutConstraint.activate([
            
            commentTextLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            commentTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            commentTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            caseTitleLabel.topAnchor.constraint(equalTo: commentTextLabel.bottomAnchor, constant: 10),
            caseTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            caseTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            commentUserLabel.topAnchor.constraint(equalTo: caseTitleLabel.bottomAnchor, constant: 5),
            commentUserLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            commentUserLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            commentUserLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            commentHeightView.topAnchor.constraint(equalTo: commentUserLabel.topAnchor),
            commentHeightView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            commentHeightView.trailingAnchor.constraint(equalTo: commentUserLabel.leadingAnchor, constant: -5),
            commentHeightView.bottomAnchor.constraint(equalTo: commentUserLabel.bottomAnchor),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
    }
    
    func configure(commentInfo: [String: Any], user: User) {
        
        let commentType = commentInfo["type"] as? Int
        let firstName = user.isCurrentUser ? "You" : user.firstName
        
        if commentType == 0 {
            // Post
            commentTextLabel.text = firstName! + " commented on a post"
        } else {
            // Clinical case
            commentTextLabel.text = firstName! + " commented on this case"
        }
        
        commentUserLabel.text = commentInfo["comment"] as? String
        caseTitleLabel.text = commentInfo["title"] as? String
        //if user.isCurrentUser {
            //label.text = "Pau Fernández Solà commented on this case"
        //}
    }
}

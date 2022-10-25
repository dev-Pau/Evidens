//
//  ProfileCommentCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/8/22.
//

import UIKit

class UserProfileCommentCell: UICollectionViewCell {
    
    var caseTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private var commentTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var commentUserLabel: UILabel = {
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

    private var separatorView: UIView = {
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
        
        addSubviews(caseTitleLabel, profileImageView, commentTextLabel, commentUserLabel, separatorView, commentHeightView)
        
        NSLayoutConstraint.activate([
            
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            separatorView.heightAnchor.constraint(equalToConstant: 1),

            commentTextLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            commentTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            commentTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            caseTitleLabel.topAnchor.constraint(equalTo: commentTextLabel.bottomAnchor, constant: 10),
            caseTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            caseTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            commentUserLabel.topAnchor.constraint(equalTo: caseTitleLabel.bottomAnchor, constant: 10),
            commentUserLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
            commentUserLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            commentUserLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            commentHeightView.topAnchor.constraint(equalTo: caseTitleLabel.bottomAnchor, constant: 10),
            commentHeightView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            commentHeightView.widthAnchor.constraint(equalToConstant: 5),
            commentHeightView.bottomAnchor.constraint(equalTo: commentUserLabel.bottomAnchor),
            
            profileImageView.leadingAnchor.constraint(equalTo: commentHeightView.trailingAnchor, constant: 5),
            profileImageView.heightAnchor.constraint(equalToConstant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 20),
            profileImageView.topAnchor.constraint(equalTo: commentHeightView.topAnchor)
        ])
        
        profileImageView.layer.cornerRadius = 20 / 2
        
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        let autoLayoutSize = systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
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
        profileImageView.sd_setImage(with: URL(string: user.profileImageUrl!))
        
    }
}

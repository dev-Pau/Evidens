//
//  ProfileCommentCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/8/22.
//

import UIKit

class UserProfileCommentCell: UICollectionViewCell {
    
    var user: User?
    
    private var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "user.profile")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private var commentTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var commentUserLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 3
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .quaternarySystemFill
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
        backgroundColor = .systemBackground
        
        addSubviews(profileImageView, commentTextLabel, commentUserLabel, separatorView)
        
        NSLayoutConstraint.activate([
            commentTextLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            commentTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            commentTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            profileImageView.leadingAnchor.constraint(equalTo: separatorView.leadingAnchor),
            profileImageView.heightAnchor.constraint(equalToConstant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 20),
            profileImageView.topAnchor.constraint(equalTo: commentTextLabel.bottomAnchor, constant: 5),
            
            commentUserLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            commentUserLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            commentUserLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            commentUserLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
        ])
        
        profileImageView.layer.cornerRadius = 20 / 2
        
    }
    
    func commentLabelAttributedString(text: String, timestamp: String) -> NSAttributedString {
 
        let attributedText = NSMutableAttributedString(string: user!.firstName! + " " + user!.lastName!, attributes: [.font: UIFont.systemFont(ofSize: 13, weight: .semibold), .foregroundColor: UIColor.secondaryLabel])
        attributedText.append(NSAttributedString(string: " \(text)  • \(timestamp)", attributes: [.font: UIFont.systemFont(ofSize: 13, weight: .regular), .foregroundColor: UIColor.secondaryLabel]))
        return attributedText
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        let autoLayoutSize = systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
    
    func configure(recentComment: RecentComment) {
        guard let user = user else { return }

        let date = NSDate(timeIntervalSince1970: recentComment.timestamp)
        //let date = NSDate
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth, .year]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        //let commentTimestamp = formatter.string(for: date)
        let commentTimestamp = formatter.string(from: date as Date, to: Date())
        
        if recentComment.type == 0 {
            // Post
            commentTextLabel.attributedText = commentLabelAttributedString(text: "commented on this post", timestamp: commentTimestamp ?? "")
        } else {
            // Clinical case
            commentTextLabel.attributedText = commentLabelAttributedString(text: "commented on this case", timestamp: commentTimestamp ?? "")
        }
        
        commentUserLabel.text = recentComment.comment
 
        if let imageUrl = user.profileImageUrl, imageUrl != "" {
            profileImageView.sd_setImage(with: URL(string: imageUrl))
        }
    }

}

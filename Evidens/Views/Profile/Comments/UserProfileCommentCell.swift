//
//  ProfileCommentCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/8/22.
//

import UIKit

class UserProfileCommentCell: UICollectionViewCell {
    
    var user: User?
    
    private var profileImageView = ProfileImageView(frame: .zero)
    
    private var commentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var commentUserLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 3
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = separatorColor
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
        
        addSubviews(profileImageView, commentLabel, commentUserLabel, separatorView)
        
        NSLayoutConstraint.activate([
            commentLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            commentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            commentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            profileImageView.heightAnchor.constraint(equalToConstant: 30),
            profileImageView.widthAnchor.constraint(equalToConstant: 30),
            profileImageView.topAnchor.constraint(equalTo: commentLabel.bottomAnchor, constant: 5),
            
            commentUserLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            commentUserLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            commentUserLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            commentUserLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
        ])
        
        profileImageView.layer.cornerRadius = 30 / 2
    }
    
    func commentLabelAttributedString(text: String, timestamp: String) -> NSAttributedString? {
        guard let user = user else { return nil }
        let attributedText = NSMutableAttributedString(string: user.name(), attributes: [.font: UIFont.systemFont(ofSize: 13, weight: .semibold), .foregroundColor: UIColor.secondaryLabel])
        attributedText.append(NSAttributedString(string: " " + text + AppStrings.Characters.dot + timestamp, attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .regular), .foregroundColor: UIColor.secondaryLabel]))
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
    
    func configure(recentComment: RawComment) {
        guard let user = user else { return }

        let date = Date(timeIntervalSince1970: recentComment.timestamp)

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth, .year]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated

        let commentTimestamp = formatter.string(from: date as Date, to: Date())
        
        commentLabel.attributedText = commentLabelAttributedString(text: recentComment.kind.title + " " + AppStrings.Profile.Comment.onThis + " " + recentComment.source.title, timestamp: commentTimestamp ?? "")
        commentUserLabel.text = recentComment.content
 
        if let imageUrl = user.profileUrl, imageUrl != "" {
            profileImageView.sd_setImage(with: URL(string: imageUrl))
        }
    }
}

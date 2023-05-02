//
//  MECommentActionButtonso.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 25/4/23.
//

import UIKit

protocol MECommentActionButtonsDelegate: AnyObject {
    func handleLike()
    //func wantsToSeeCommentLikes()
    func wantsToSeeReplies()
}

class MECommentActionButtons: UIView {
    weak var delegate: MECommentActionButtonsDelegate?
    
    lazy var likeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return button
    }()
    
    lazy var likesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        //label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLikesTap)))
        return label
    }()
    
    lazy var commentButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "bubble.left", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label).scalePreservingAspectRatio(targetSize: CGSize(width: 22, height: 22))
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return button
    }()
    
    lazy var commentsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.textColor = primaryColor
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleComment)))
        return label
    }()
    
    lazy var commentsHintLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        //label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLikesTap)))
        return label
    }()
    
    
    lazy var ownerPostImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true
        addSubviews(likeButton, likesLabel, commentButton, commentsHintLabel, ownerPostImageView, commentsLabel)
        NSLayoutConstraint.activate([
            likeButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            likeButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            likeButton.heightAnchor.constraint(equalToConstant: 20),
            likeButton.widthAnchor.constraint(equalToConstant: 20),
            
            likesLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            likesLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 5),
            likesLabel.widthAnchor.constraint(equalToConstant: 30),
            //likesLabel.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor, constant: -20),
            
            commentButton.leadingAnchor.constraint(equalTo: likesLabel.trailingAnchor, constant: 10),
            commentButton.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            commentButton.widthAnchor.constraint(equalToConstant: 22),
            commentButton.heightAnchor.constraint(equalToConstant: 22),
            
            commentsHintLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            commentsHintLabel.leadingAnchor.constraint(equalTo: commentButton.trailingAnchor, constant: 5),
            
            commentsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            commentsLabel.centerYAnchor.constraint(equalTo: likesLabel.centerYAnchor),
            
            ownerPostImageView.centerYAnchor.constraint(equalTo: commentButton.centerYAnchor),
            ownerPostImageView.trailingAnchor.constraint(equalTo: commentsLabel.leadingAnchor, constant: -5),
            ownerPostImageView.heightAnchor.constraint(equalToConstant: 20),
            ownerPostImageView.widthAnchor.constraint(equalToConstant: 20),
            
        ])
    }
    
    @objc func handleLike() {
        HomeHeartAnimation.shared.animateLikeTap(likeButton)
        delegate?.handleLike()
    }
    
    @objc func handleComment() {
        delegate?.wantsToSeeReplies()
    }
}

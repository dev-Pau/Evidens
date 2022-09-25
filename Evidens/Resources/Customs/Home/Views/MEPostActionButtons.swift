//
//  File.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/6/22.
//

import UIKit

protocol MEPostActionButtonsDelegate: AnyObject {
    func handleLikes()
    func handleComments()
    func handleBookmark()
    func handleShowLikes()
}

class MEPostActionButtons: UIView {
    
    weak var delegate: MEPostActionButtonsDelegate?
    
    private let bottomSeparatorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = lightGrayColor
        return label
    }()
    
    
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
        label.textColor = grayColor
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLikesTap)))
        return label
    }()
    
    
    var commentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = grayColor
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    
    
    
    lazy var commentButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.image = UIImage(named: "comment")?.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25))
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return button
    }()

    lazy var bookmarkButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.addTarget(self, action: #selector(handleBookmark), for: .touchUpInside)
        return button
    }()
    

    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubviews(likeButton, likesLabel, commentButton, commentLabel, bottomSeparatorLabel, bookmarkButton)
        
        NSLayoutConstraint.activate([
            likeButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            likeButton.topAnchor.constraint(equalTo: topAnchor),
            
            likesLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            likesLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: -5),
            likesLabel.widthAnchor.constraint(equalToConstant: 30),
            
            commentButton.leadingAnchor.constraint(equalTo: likesLabel.trailingAnchor, constant: 10),
            commentButton.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            commentButton.widthAnchor.constraint(equalToConstant: 25),
            commentButton.heightAnchor.constraint(equalToConstant: 25),
            
            commentLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            commentLabel.leadingAnchor.constraint(equalTo: commentButton.trailingAnchor, constant: 5),
            commentLabel.widthAnchor.constraint(equalToConstant: 30),
            
            bookmarkButton.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            bookmarkButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 25),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 25),
            
            bottomSeparatorLabel.topAnchor.constraint(equalTo: topAnchor),
            bottomSeparatorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            bottomSeparatorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            bottomSeparatorLabel.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
    
    @objc func handleLike() {
        HomeHeartAnimation.shared.animateLikeTap(likeButton)
        delegate?.handleLikes()
    }
    
    
    @objc func handleComment() {
        delegate?.handleComments()
    }
    
    @objc func handleBookmark() {
        HomeHeartAnimation.shared.animateLikeTap(bookmarkButton)
        delegate?.handleBookmark()
    }
    
    @objc func handleLikesTap() {
        delegate?.handleShowLikes()
    }
}

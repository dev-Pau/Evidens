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
        button.configuration?.baseForegroundColor = .black
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return button
    }()
    
    lazy var likesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.textColor = grayColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLikesTap)))
        return label
    }()
    
    
    var commentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = grayColor
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    
    
    
    lazy var commentButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "text.bubble", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        button.configuration?.baseForegroundColor = .black
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return button
    }()

    lazy var bookmarkButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "bookmark", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        button.configuration?.baseForegroundColor = .black
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
            likesLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: -10),
            likesLabel.widthAnchor.constraint(equalToConstant: 30),
            
            commentButton.leadingAnchor.constraint(equalTo: likesLabel.trailingAnchor, constant: 5),
            commentButton.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            
            commentLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            commentLabel.leadingAnchor.constraint(equalTo: commentButton.trailingAnchor, constant: -10),
            
            bookmarkButton.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            bookmarkButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 30),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 30),
            
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

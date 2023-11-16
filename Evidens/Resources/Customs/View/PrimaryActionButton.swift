//
//  PrimaryActionButton.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/6/22.
//

import UIKit

protocol PrimaryActionButtonDelegate: AnyObject {
    func handleLikes()
    func handleComments()
    func handleBookmark()
    func handleShowLikes()
}

class PrimaryActionButton: UIView {
    
    weak var delegate: PrimaryActionButtonDelegate?

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
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLikesTap)))
        return label
    }()
    
    var commentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()

    lazy var commentButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.image = UIImage(named: AppStrings.Assets.comment)?.scalePreservingAspectRatio(targetSize: CGSize(width: 22, height: 22)).withTintColor(.secondaryLabel)
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
        backgroundColor = .systemBackground
        
        let buttonsStackView = UIStackView(arrangedSubviews: [likeButton, commentButton, bookmarkButton])
        buttonsStackView.distribution = .equalSpacing
        buttonsStackView.axis = .horizontal
        buttonsStackView.alignment = .leading
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false

        addSubviews(buttonsStackView, likesLabel, commentLabel)
        NSLayoutConstraint.activate([
            buttonsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonsStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            likesLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 7),
            likesLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            likesLabel.trailingAnchor.constraint(equalTo: commentButton.leadingAnchor, constant: -10),
            
            commentLabel.leadingAnchor.constraint(equalTo: commentButton.trailingAnchor, constant: 7),
            commentLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            
            likeButton.heightAnchor.constraint(equalToConstant: 22),
            likeButton.widthAnchor.constraint(equalToConstant: 18),
            
            commentButton.widthAnchor.constraint(equalToConstant: 22),
            commentButton.heightAnchor.constraint(equalToConstant: 22),
            
            bookmarkButton.heightAnchor.constraint(equalToConstant: 22),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 22),
        ])
    }
    
    @objc func handleLike() {
        ToggleTapAnimation.shared.animate(likeButton)
        delegate?.handleLikes()
    }
    
    
    @objc func handleComment() {
        delegate?.handleComments()
    }
    
    @objc func handleBookmark() {
        ToggleTapAnimation.shared.animate(bookmarkButton)
        delegate?.handleBookmark()
    }
    
    @objc func handleLikesTap() {
        delegate?.handleShowLikes()
    }
}

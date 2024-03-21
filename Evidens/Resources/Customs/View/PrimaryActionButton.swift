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
        label.textColor = K.Colors.primaryGray
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = UIFont.addFont(size: 13, scaleStyle: .largeTitle, weight: .semibold, scales: false)
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLikesTap)))
        return label
    }()
    
    var commentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = K.Colors.primaryGray
        label.textAlignment = .left
        label.font = UIFont.addFont(size: 13, scaleStyle: .largeTitle, weight: .semibold, scales: false)
        label.numberOfLines = 0
        return label
    }()

    lazy var commentButton: UIButton = {
        let button = UIButton()
        let buttonSize: CGFloat = UIDevice.isPad ? 30 : 25
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.image = UIImage(named: AppStrings.Assets.comment)?.scalePreservingAspectRatio(targetSize: CGSize(width: buttonSize, height: buttonSize)).withTintColor(K.Colors.primaryGray)
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
        
        let buttonsStackView = UIStackView(arrangedSubviews: [commentButton, likeButton, bookmarkButton])
        buttonsStackView.distribution = .equalSpacing
        buttonsStackView.axis = .horizontal
        buttonsStackView.alignment = .leading
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let size: CGFloat = UIDevice.isPad ? 30 : 25

        addSubviews(buttonsStackView, likesLabel, commentLabel)
        NSLayoutConstraint.activate([
            buttonsStackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            buttonsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonsStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            likesLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 5),
            likesLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            likesLabel.trailingAnchor.constraint(equalTo: bookmarkButton.leadingAnchor, constant: -10),
            
            commentLabel.leadingAnchor.constraint(equalTo: commentButton.trailingAnchor, constant: 5),
            commentLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            
            likeButton.heightAnchor.constraint(equalToConstant: size),
            likeButton.widthAnchor.constraint(equalToConstant: size),
            
            commentButton.widthAnchor.constraint(equalToConstant: size),
            commentButton.heightAnchor.constraint(equalToConstant: size),
            
            bookmarkButton.heightAnchor.constraint(equalToConstant: size),
            bookmarkButton.widthAnchor.constraint(equalToConstant: size),
        ])
    }
    
    @objc func handleLike() {
        guard let phase = UserDefaults.getPhase(), phase == .verified else {
            ContentManager.shared.permissionAlert(kind: .reaction)
            return
        }
        
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

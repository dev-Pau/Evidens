//
//  MECommentActionButtonso.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 25/4/23.
//

import UIKit

protocol CommentActionButtonViewDelegate: AnyObject {
    func handleLike()
    func wantsToSeeReplies()
}

class CommentActionButtonView: UIView {
    weak var delegate: CommentActionButtonViewDelegate?
    
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
        label.font = UIFont.addFont(size: 13, scaleStyle: .largeTitle, weight: .semibold, scales: false)
        return label
    }()
    
    lazy var commentButton: UIButton = {
        let button = UIButton()
        let buttonSize: CGFloat = UIDevice.isPad ? 30 : 25
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.image = UIImage(named: AppStrings.Assets.comment)?.scalePreservingAspectRatio(targetSize: CGSize(width: buttonSize, height: buttonSize)).withTintColor(.secondaryLabel)
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return button
    }()

    lazy var commentsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = UIFont.addFont(size: 13, scaleStyle: .largeTitle, weight: .semibold, scales: false)
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
        
        let buttonsStackView = UIStackView(arrangedSubviews: [likeButton, commentButton])
        buttonsStackView.distribution = .equalSpacing
        buttonsStackView.axis = .horizontal
        buttonsStackView.alignment = .leading
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonsWidth: CGFloat = UIDevice.isPad ? 230 : 130
        let size: CGFloat = UIDevice.isPad ? 30 : 25
       
        addSubviews(buttonsStackView, likesLabel, commentsLabel)
        NSLayoutConstraint.activate([
            
            buttonsStackView.widthAnchor.constraint(equalToConstant: buttonsWidth),
            buttonsStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            buttonsStackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            buttonsStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            likesLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 5),
            likesLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            likesLabel.trailingAnchor.constraint(equalTo: commentButton.leadingAnchor, constant: -10),
            
            commentsLabel.leadingAnchor.constraint(equalTo: commentButton.trailingAnchor, constant: 5),
            commentsLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            
            likeButton.heightAnchor.constraint(equalToConstant: size),
            likeButton.widthAnchor.constraint(equalToConstant: size),
            
            commentButton.widthAnchor.constraint(equalToConstant: size),
            commentButton.heightAnchor.constraint(equalToConstant: size),
        ])
    }
    
    @objc func handleLike() {
        guard let phase = UserDefaults.getPhase(), phase == .verified else {
            ContentManager.shared.permissionAlert(kind: .reaction)
            return
        }
        
        ToggleTapAnimation.shared.animate(likeButton)
        delegate?.handleLike()
    }
    
    @objc func handleComment() {
        delegate?.wantsToSeeReplies()
    }
}

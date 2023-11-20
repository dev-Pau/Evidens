//
//  MECommentActionButtonso.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 25/4/23.
//

import UIKit
import Lottie

protocol CommentActionButtonViewDelegate: AnyObject {
    func handleLike()
    func wantsToSeeReplies()
}

class CommentActionButtonView: UIView {
    weak var delegate: CommentActionButtonViewDelegate?
    
    private var animationView: LottieAnimationView!
    
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
        return label
    }()
    
    lazy var commentButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.image = UIImage(named: AppStrings.Assets.comment)?.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25)).withTintColor(.secondaryLabel)
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
        label.font = .systemFont(ofSize: 13, weight: .semibold)
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
        
        animationView = LottieAnimationView()
        animationView.backgroundColor = .systemBackground
        animationView.animation = LottieAnimation.named("like")
        animationView.contentMode = .scaleAspectFit
        animationView.animationSpeed = 2
        animationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLike)))
        
        addSubviews(buttonsStackView, likesLabel, commentsLabel, animationView)
        NSLayoutConstraint.activate([
            buttonsStackView.widthAnchor.constraint(equalToConstant: 130),
            buttonsStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            buttonsStackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            
            likesLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 5),
            likesLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            
            commentsLabel.leadingAnchor.constraint(equalTo: commentButton.trailingAnchor, constant: 5),
            commentsLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            
            likeButton.heightAnchor.constraint(equalToConstant: 22),
            likeButton.widthAnchor.constraint(equalToConstant: 24),
            
            commentButton.widthAnchor.constraint(equalToConstant: 25),
            commentButton.heightAnchor.constraint(equalToConstant: 25),
        ])
        
        animationView.isHidden = false
    }
    
    @objc func handleLike() {
        ToggleTapAnimation.shared.animate(likeButton)
        delegate?.handleLike()
    }
    
    @objc func handleComment() {
        delegate?.wantsToSeeReplies()
    }
}

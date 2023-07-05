//
//  MEDetailsActionButtons.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 4/7/23.
//

import UIKit
/*
protocol MEPostActionButtonsDelegate: AnyObject {
    func handleLikes()
    func handleComments()
    func handleBookmark()
    func handleShowLikes()
}
*/

protocol MEDetailsActionButtonsDelegate: AnyObject {
    func handleLikes()
    func handleShowLikes()
}

class MEDetailsActionButtons: UIView {
    
    weak var delegate: MEDetailsActionButtonsDelegate?

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
    
    var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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

        addSubviews(likeButton, likesLabel, separatorView)
        
        NSLayoutConstraint.activate([
            likeButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            likeButton.topAnchor.constraint(equalTo: topAnchor),
            
            likesLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            likesLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: -5),
            likesLabel.widthAnchor.constraint(equalToConstant: 30),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4)
        ])
    }
    
    @objc func handleLike() {
        HomeHeartAnimation.shared.animateLikeTap(likeButton)
        delegate?.handleLikes()
    }
    
    @objc func handleLikesTap() {
        delegate?.handleShowLikes()
    }
}

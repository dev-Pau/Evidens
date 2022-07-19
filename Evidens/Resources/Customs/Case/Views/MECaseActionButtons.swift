//
//  MECaseActionButtons.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/7/22.
//

import UIKit

import UIKit

protocol MECaseActionButtonsDelegate: AnyObject {
    func handleLikes()
    func handleComments()
    func handleShare()
}

class MECaseActionButtons: UIView {
    
    weak var delegate: MECaseActionButtonsDelegate?
    
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

        button.configuration?.imagePlacement = .top
        
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return button
    }()
    
    
    lazy var commentButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()

        button.configuration?.image = UIImage(systemName: "bubble.right", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
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
        
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
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
        

        addSubviews(bottomSeparatorLabel, likeButton, commentButton, bookmarkButton)
        
        NSLayoutConstraint.activate([
           
            bottomSeparatorLabel.topAnchor.constraint(equalTo: topAnchor),
            bottomSeparatorLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomSeparatorLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomSeparatorLabel.heightAnchor.constraint(equalToConstant: 1),
            
            likeButton.topAnchor.constraint(equalTo: bottomSeparatorLabel.bottomAnchor, constant: 5),
            likeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            likeButton.heightAnchor.constraint(equalToConstant: 30),
            likeButton.widthAnchor.constraint(equalToConstant: 30),
            
            commentButton.topAnchor.constraint(equalTo: bottomSeparatorLabel.bottomAnchor, constant: 5),
            commentButton.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 5),
            commentButton.heightAnchor.constraint(equalToConstant: 30),
            commentButton.widthAnchor.constraint(equalToConstant: 30),
            
            bookmarkButton.topAnchor.constraint(equalTo: bottomSeparatorLabel.bottomAnchor, constant: 5),
            bookmarkButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 30),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 30),
        ])
    }
    
    @objc func handleLike() {
        HomeHeartAnimation.shared.animateLikeTap(likeButton)
        delegate?.handleLikes()
    }
    
    
    @objc func handleComment() {
        delegate?.handleComments()
    }
}


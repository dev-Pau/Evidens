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
    
    
    lazy var commentButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()

        button.configuration?.image = UIImage(systemName: "bubble.right", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.scalePreservingAspectRatio(targetSize: CGSize(width: 26, height: 26))
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
            
            commentButton.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor, constant: 1),
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
    
    @objc func handleBookmark() {
        delegate?.handleBookmark()
    }
}

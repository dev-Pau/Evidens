//
//  MECaseActionButtons.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/7/22.
//

import UIKit

class MECaseActionButtons: UIView {
    
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

        addSubviews(likeButton, bottomSeparatorLabel, bookmarkButton)
        
        NSLayoutConstraint.activate([
            likeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -5),
            likeButton.topAnchor.constraint(equalTo: topAnchor),
            
            bookmarkButton.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            bookmarkButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 30),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 30),
            
            bottomSeparatorLabel.topAnchor.constraint(equalTo: topAnchor),
            bottomSeparatorLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomSeparatorLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomSeparatorLabel.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
    
    @objc func handleLike() {
        HomeHeartAnimation.shared.animateLikeTap(likeButton)
        delegate?.handleLikes()
    }
    
    @objc func handleBookmark() {
        HomeHeartAnimation.shared.animateLikeTap(bookmarkButton)
        delegate?.handleBookmark()
    }
}

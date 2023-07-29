//
//  CaseActionButtonView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/7/22.
//

import UIKit

class CaseActionButtonView: UIView {
    
    weak var delegate: PrimaryActionButtonDelegate?
    
    private let bottomSeparatorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = separatorColor
        return label
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.baseForegroundColor = .label
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return button
    }()
    
    lazy var bookmarkButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.image = UIImage(named: AppStrings.Assets.bookmark)
        button.configuration?.baseForegroundColor = .label
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

        addSubviews(likeButton, bottomSeparatorLabel, bookmarkButton)
        
        NSLayoutConstraint.activate([
            likeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -5),
            likeButton.topAnchor.constraint(equalTo: topAnchor),
            
            bookmarkButton.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            bookmarkButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 25),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 25),
            
            bottomSeparatorLabel.topAnchor.constraint(equalTo: topAnchor),
            bottomSeparatorLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomSeparatorLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomSeparatorLabel.heightAnchor.constraint(equalToConstant: 0.4),
        ])
    }
    
    @objc func handleLike() {
        ToggleTapAnimation.shared.animate(likeButton)
        delegate?.handleLikes()
    }
    
    @objc func handleBookmark() {
        ToggleTapAnimation.shared.animate(bookmarkButton)
        delegate?.handleBookmark()
    }
}

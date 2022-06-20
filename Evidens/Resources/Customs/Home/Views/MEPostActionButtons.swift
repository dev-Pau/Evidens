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
    func handleShare()
    func handleSend()
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
        
        button.configuration?.baseBackgroundColor = .white
        button.configuration?.baseForegroundColor = blackColor
        
        button.configuration?.imagePadding = 3
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 13, weight: .semibold)
        
        button.configuration?.attributedTitle = AttributedString("Like", attributes: container)
        button.configuration?.imagePlacement = .top

        button.configuration?.image = UIImage(systemName: "heart")
        
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return button
    }()
    
    
    lazy var commentButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        
        button.configuration?.baseBackgroundColor = .white
        button.configuration?.baseForegroundColor = blackColor

        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 13, weight: .semibold)
        
        button.configuration?.imagePadding = 3
        
        button.configuration?.attributedTitle = AttributedString("Comment", attributes: container)
        button.configuration?.imagePlacement = .top

        button.configuration?.image = UIImage(named: "comment")
        
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        
        button.configuration?.baseBackgroundColor = .white
        button.configuration?.baseForegroundColor = blackColor

        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 13, weight: .semibold)
        
        button.configuration?.attributedTitle = AttributedString("Send", attributes: container)
        button.configuration?.imagePlacement = .top
        
        button.configuration?.imagePadding = 3

        button.configuration?.image = UIImage(named: "paperplane")
        return button
    }()
    
    lazy var shareButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        
        button.configuration?.baseBackgroundColor = .white
        button.configuration?.baseForegroundColor = blackColor

        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 13, weight: .semibold)
        
        button.configuration?.attributedTitle = AttributedString("Share", attributes: container)
        button.configuration?.imagePlacement = .top
        
        button.configuration?.imagePadding = 3

        button.configuration?.image = UIImage(named: "share")
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
        
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, shareButton, sendButton])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubviews(bottomSeparatorLabel, stackView)
        
        NSLayoutConstraint.activate([
           
            bottomSeparatorLabel.topAnchor.constraint(equalTo: topAnchor),
            bottomSeparatorLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomSeparatorLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomSeparatorLabel.heightAnchor.constraint(equalToConstant: 1),
            
            stackView.topAnchor.constraint(equalTo: bottomSeparatorLabel.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
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

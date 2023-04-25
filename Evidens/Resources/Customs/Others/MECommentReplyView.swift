//
//  MECommentReplyView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 25/4/23.
//

import UIKit

class MECommentReplyView: UIView {
    
    lazy var commentsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.textColor = primaryColor
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        //label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLikesTap)))
        return label
    }()
    
    private let ownerPostImageView: UIImageView = {
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
        addSubviews(commentsLabel, ownerPostImageView)
        NSLayoutConstraint.activate([
            ownerPostImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            ownerPostImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            ownerPostImageView.heightAnchor.constraint(equalToConstant: 30),
            ownerPostImageView.widthAnchor.constraint(equalToConstant: 30),
            
            commentsLabel.centerYAnchor.constraint(equalTo: ownerPostImageView.centerYAnchor),
            commentsLabel.leadingAnchor.constraint(equalTo: ownerPostImageView.leadingAnchor),
            //likesLabel.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor, constant: -20),
        ])
        commentsLabel.layer.cornerRadius = 30 / 2
    }
}

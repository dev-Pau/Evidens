//
//  MEPostInfoView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/6/22.
//

import UIKit

class MEPostInfoView: UIView {
    
    var comments: Int = 0
    var shares: Int = 0
    var commentText: String = ""
    var shareText: String = ""
    
    var commentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = grayColor
        label.font = .systemFont(ofSize: 12, weight: .semibold)

        return label
    }()
    
    var shareLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = grayColor
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        return label
    }()
    
    private let dotSeparator: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "dot")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(comments: Int, commentText: String, shares: Int, shareText: String) {
        super.init(frame: .zero)
        self.comments = comments
        self.commentText = commentText
        self.shares = shares
        self.shareText = shareText
        configure(comments: comments, commentText: commentText, shares: shares, shareText: shareText)
    }
    
    func configure(comments: Int, commentText: String, shares: Int, shareText: String) {
        print(comments)
        translatesAutoresizingMaskIntoConstraints = false
        
        commentLabel.removeFromSuperview()
        shareLabel.removeFromSuperview()
        dotSeparator.removeFromSuperview()
        
        let stackView = UIStackView(arrangedSubviews: [commentLabel, dotSeparator, shareLabel])
        
        commentLabel.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        addSubview(stackView)
        
        
        if comments != 0 && shares != 0 {
            NSLayoutConstraint.activate([
                stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            ])
            commentLabel.text = commentText
            shareLabel.text = shareText
            return
        }
        
        if comments == 0 && shares != 0 {
            stackView.removeFromSuperview()
            addSubview(shareLabel)
            NSLayoutConstraint.activate([
                shareLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                shareLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            ])
            shareLabel.text = shareText
            return
            
        }
        if comments != 0 && shares == 0 {
            stackView.removeFromSuperview()
            addSubview(commentLabel)
            NSLayoutConstraint.activate([
                commentLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                commentLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            ])
            commentLabel.text = commentText
            return
        }
        
        stackView.removeFromSuperview()
        commentLabel.removeFromSuperview()
        shareLabel.removeFromSuperview()
        dotSeparator.removeFromSuperview()
    }
}

//
//  MECaseInfoView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/7/22.
//

import UIKit

class MECaseInfoView: UIView {
    
    var comments: Int = 0
    var views: Int = 0
    var commentText: String = ""
    var viewText: String = ""
    
    var commentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = grayColor
        label.font = .systemFont(ofSize: 12, weight: .semibold)

        return label
    }()
    
    var viewLabel: UILabel = {
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
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(comments: Int, commentText: String, views: Int, viewText: String) {
        super.init(frame: .zero)
        self.comments = comments
        self.commentText = commentText
        self.views = views
        self.viewText = viewText
        configure(comments: comments, commentText: commentText, views: views, viewText: viewText)
    }
    
    func configure(comments: Int, commentText: String, views: Int, viewText: String) {
        translatesAutoresizingMaskIntoConstraints = false
        
        commentLabel.removeFromSuperview()
        viewLabel.removeFromSuperview()
        dotSeparator.removeFromSuperview()
        
        let stackView = UIStackView(arrangedSubviews: [commentLabel, dotSeparator, viewLabel])
        
        commentLabel.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 5
        addSubview(stackView)
        
        
        if comments != 0 && views != 0 {
            NSLayoutConstraint.activate([
                stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            ])
            commentLabel.text = commentText
            viewLabel.text = viewText
            return
        }
        
        if comments == 0 && views != 0 {
            stackView.removeFromSuperview()
            addSubview(viewLabel)
            NSLayoutConstraint.activate([
                viewLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                viewLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            ])
            viewLabel.text = viewText
            return
            
        }
        if comments != 0 && views == 0 {
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
        viewLabel.removeFromSuperview()
        dotSeparator.removeFromSuperview()
    }
}

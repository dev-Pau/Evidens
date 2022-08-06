//
//  UserProfileNoPostCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/8/22.
//

import UIKit

class UserProfileNoPostCell: UICollectionViewCell {
    
    private var postTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var postTextSubLabel: UILabel = {
        let label = UILabel()
        label.textColor = grayColor
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 3
        label.text = "You will be able to see their posts here."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = lightGrayColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        backgroundColor = .white
        
        addSubviews(postTextLabel, postTextSubLabel, separatorView)
        
        NSLayoutConstraint.activate([

            postTextLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            postTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            postTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            postTextSubLabel.topAnchor.constraint(equalTo: postTextLabel.bottomAnchor, constant: 5),
            postTextSubLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            postTextSubLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            postTextSubLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
    }
    
    func configure(name: String) {
        postTextLabel.text = "\(name) hasn't posted lately."
    }
}


//
//  File.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/6/22.
//

import UIKit

class HomeLikesCell: UITableViewCell {
    
    lazy var profileImageView: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "home.fill")
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        return iv
    }()
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .bold)
        return label
    }()

    var userCategoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = grayColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Physiotherapist"
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        return label
    }()
    
    
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        let stack = UIStackView(arrangedSubviews: [nameLabel, userCategoryLabel])
        stack.axis = .vertical
        stack.distribution = .fillEqually

        stack.translatesAutoresizingMaskIntoConstraints = false
        
        
        addSubviews(profileImageView, stack)
        
        NSLayoutConstraint.activate([
            profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),
            
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            stack.heightAnchor.constraint(equalToConstant: 40),
            stack.widthAnchor.constraint(equalToConstant: 300)
        
        ])
        
        profileImageView.layer.cornerRadius = 40 / 2
    }
}

//
//  File.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/6/22.
//

import UIKit

class HomeLikesCell: UITableViewCell {
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        label.lineBreakMode = .byTruncatingMiddle
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let professionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = grayColor
        label.lineBreakMode = .byTruncatingMiddle
        label.translatesAutoresizingMaskIntoConstraints = false
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
        
        addSubviews(profileImageView, nameLabel, professionLabel)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
          
            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            professionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            professionLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            professionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
        ])
        
        profileImageView.layer.cornerRadius = 40 / 2
    }
    
    func set(profileImageUrl: String, name: String, lastName: String, profession: String, speciality: String, category: String) {
        profileImageView.sd_setImage(with: URL(string: profileImageUrl))
        nameLabel.text = name + " " + lastName + " · " + category
        professionLabel.text = profession + " · " + speciality
    }
}

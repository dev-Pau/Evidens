//
//  TopCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/5/22.
//

import UIKit
import SwiftUI

class TopPeopleCell: UITableViewCell {
    
    //MARK: - Properties
    
    var viewModel: TopPeopleCellViewModel? {
        didSet {
            configure()
        }
    }
    
    private lazy var profileImageView: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = lightColor
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        return label
    }()
    /*
    private lazy var contactButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "person.fill.badge.plus"), for: .normal)
        button.tintColor = blackColor
        button.layer.borderColor = grayColor.cgColor
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        return button
    }()
     */
     
    private let userCategoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = grayColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 2
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        profileImageView.setDimensions(height: 45, width: 45)
        profileImageView.layer.cornerRadius = 45/2
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 10, paddingLeft: 15)
        
        addSubview(nameLabel)
        nameLabel.anchor(top: profileImageView.topAnchor, left: profileImageView.rightAnchor, paddingLeft: 9)
        
        addSubview(userCategoryLabel)
        userCategoryLabel.anchor(top: nameLabel.bottomAnchor, left: nameLabel.leftAnchor, paddingTop: 2)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    func configure() {
        guard let viewModel = viewModel else { return }
        profileImageView.sd_setImage(with: viewModel.userProfileImageUrl)
        nameLabel.text = viewModel.fullName
        userCategoryLabel.text = viewModel.profession

    }
}

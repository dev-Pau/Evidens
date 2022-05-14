//
//  CollectionViewCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/5/22.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.backgroundColor = .lightGray
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapUsername))
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = "Pau Fernández Solà"
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(profileImageView)
        profileImageView.setDimensions(height: 60, width: 60)
        profileImageView.layer.cornerRadius = 60/2
        profileImageView.anchor(top: topAnchor)
        profileImageView.centerX(inView: self)
        
        addSubview(nameLabel)
        nameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 3)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Actions
    @objc func didTapUsername() {
        
    }
    
    
}

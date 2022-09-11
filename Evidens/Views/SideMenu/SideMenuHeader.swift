//
//  SideMenuHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/9/22.
//

import UIKit

protocol SideMenuHeaderDelegate: AnyObject {
    func didTapHeader()
}

class SideMenuHeader: UICollectionReusableView {
    
    weak var delegate: SideMenuHeaderDelegate?
    
    private lazy var userImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.masksToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = lightGrayColor
        iv.isUserInteractionEnabled = false
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    private let viewProfileLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.text = "View profile"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = grayColor
        label.textAlignment = .left
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
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleHeaderTap)))
        
        addSubviews(userImageView, nameLabel, viewProfileLabel, separatorView)
        NSLayoutConstraint.activate([
            userImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            userImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            userImageView.heightAnchor.constraint(equalToConstant: 60),
            userImageView.widthAnchor.constraint(equalToConstant: 60),
            
            nameLabel.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: userImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -70),
            
            viewProfileLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            viewProfileLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            viewProfileLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            separatorView.topAnchor.constraint(equalTo: viewProfileLabel.bottomAnchor, constant: 20),
            separatorView.leadingAnchor.constraint(equalTo: viewProfileLabel.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: viewProfileLabel.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        userImageView.layer.cornerRadius = 60 / 2
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        if let imageString = UserDefaults.standard.value(forKey: "userProfileImageUrl") as? String {
            userImageView.sd_setImage(with: URL(string: imageString))
        }
        
        if let name = UserDefaults.standard.value(forKey: "name") as? String {
            nameLabel.text = name
        }
    }
    
    @objc func handleHeaderTap() {
        print("HEADER")
        delegate?.didTapHeader()
    }
    
    
}

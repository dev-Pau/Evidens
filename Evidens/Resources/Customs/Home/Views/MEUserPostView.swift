//
//  MEUserPostView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/6/22.
//

import UIKit

protocol MEUserPostViewDelegate: AnyObject {
    func didTapProfile()
    func didTapThreeDots()
}

class MEUserPostView: UIView {
    
    weak var delegate: MEUserPostViewDelegate?
    
    private var paddingTop: CGFloat =  10
    private var paddingLeft: CGFloat = 10
    
    lazy var profileImageView = MEProfileImageView(frame: .zero)
    
    lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private lazy var dotsImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.image = UIImage(systemName: "ellipsis")
        button.configuration?.baseForegroundColor = .black
        button.configuration?.baseBackgroundColor = .white
        button.configuration?.buttonSize = .small
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(handleThreeDots), for: .touchUpInside)
        return button
    }()
    
    let userInfoCategoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = grayColor
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private let clockImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "clock")
        return iv
    }()
    
    let privacyImage: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        return button
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        
        button.configuration?.baseBackgroundColor = .white

        button.configuration?.image = UIImage(named: "paperplane")?.withTintColor(grayColor)
        return button
    }()
    
    let postTimeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = grayColor
        return label
    }()


    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapProfile)))
        
        addSubviews(profileImageView, usernameLabel, dotsImageButton, userInfoCategoryLabel, clockImage, postTimeLabel, privacyImage)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: paddingLeft),
            profileImageView.heightAnchor.constraint(equalToConstant: 53),
            profileImageView.widthAnchor.constraint(equalToConstant: 53),
            
            dotsImageButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            dotsImageButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -paddingLeft),
            dotsImageButton.heightAnchor.constraint(equalToConstant: 20),
            dotsImageButton.widthAnchor.constraint(equalToConstant: 20),
            
            usernameLabel.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop),
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: paddingLeft),
            usernameLabel.trailingAnchor.constraint(equalTo: dotsImageButton.leadingAnchor, constant: -paddingLeft),
            usernameLabel.heightAnchor.constraint(equalToConstant: 15),
            
            userInfoCategoryLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 2),
            userInfoCategoryLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            userInfoCategoryLabel.trailingAnchor.constraint(equalTo: usernameLabel.trailingAnchor),
            //userCategoryLabel.heightAnchor.constraint(equalToConstant: 20),
            
            clockImage.topAnchor.constraint(equalTo: userInfoCategoryLabel.bottomAnchor, constant: 2),
            clockImage.leadingAnchor.constraint(equalTo: userInfoCategoryLabel.leadingAnchor),
            clockImage.heightAnchor.constraint(equalToConstant: 9.6),
            clockImage.widthAnchor.constraint(equalToConstant: 9.6),
            
            postTimeLabel.centerYAnchor.constraint(equalTo: clockImage.centerYAnchor),
            postTimeLabel.leadingAnchor.constraint(equalTo: clockImage.trailingAnchor, constant: 5),
            postTimeLabel.heightAnchor.constraint(equalToConstant: 20),
            //postTimeLabel.trailingAnchor.constraint(equalTo: userCategoryLabel.trailingAnchor),
            
            privacyImage.centerYAnchor.constraint(equalTo: postTimeLabel.centerYAnchor),
            privacyImage.leadingAnchor.constraint(equalTo: postTimeLabel.trailingAnchor),
            privacyImage.heightAnchor.constraint(equalToConstant: 11.6),
            privacyImage.widthAnchor.constraint(equalToConstant: 11.6),  
        ])
        
        profileImageView.layer.cornerRadius = 53 / 2
        
    }
    
    @objc func didTapProfile() {
        delegate?.didTapProfile()
    }
    
    @objc func handleThreeDots() {
        delegate?.didTapThreeDots()
    }
}

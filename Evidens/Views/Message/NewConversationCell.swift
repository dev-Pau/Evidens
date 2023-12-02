//
//  NewConversationCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/2/22.
//
import UIKit
import SDWebImage


class NewConversationCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    private lazy var profileImageView = ProfileImageView(frame: .zero)
    
    private let name: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 16, scaleStyle: .title2, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        return label
    }()
    
    private let discipline: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.numberOfLines = 1
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(profileImageView, name, discipline, activityIndicator, separatorView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .systemBackground
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            profileImageView.heightAnchor.constraint(equalToConstant: 43),
            profileImageView.widthAnchor.constraint(equalToConstant: 43),
            
            activityIndicator.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            name.bottomAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            name.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            name.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            discipline.topAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            discipline.leadingAnchor.constraint(equalTo: name.leadingAnchor),
            discipline.trailingAnchor.constraint(equalTo: name.trailingAnchor),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4)
        ])
        
        profileImageView.layer.cornerRadius = 43 / 2
    }
    
    //MARK: - Helpers

    func set(user: User) {
        name.text = user.name()
        discipline.text = user.details()
        
        if let imageUrl = user.profileUrl, imageUrl != "" {
           profileImageView.sd_setImage(with: URL(string: imageUrl))
        }
    }
    
    func animate(_ animate: Bool) {
        animate ? activityIndicator.stopAnimating() : activityIndicator.startAnimating()
    }
}

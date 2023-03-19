//
//  MEPrimaryLockView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/3/23.
//

import UIKit

class MEPrimaryBlurLockView: UIView {
    

    private let lockImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        iv.image = UIImage(systemName: "lock.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        iv.layer.cornerRadius = 5
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 35, weight: .heavy)
        label.textColor = .label
        label.text = "These features are protected."
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.text = "Only confirmed and verified users have access to all features. Check back later to verify your status."
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(blurView, at: 0)
        blurView.frame = bounds
        
        addSubviews(lockImageView, titleLabel, descriptionLabel)
        NSLayoutConstraint.activate([
            lockImageView.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -40),
            lockImageView.heightAnchor.constraint(equalToConstant: 120),
            lockImageView.widthAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: lockImageView.bottomAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
            
            //lockImageView.topAnchor.constra.constraint(equalTo: centerXAnchor),
            //lockImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            //lockImageView.heightAnchor.constraint(equalToConstant: 120),
            //lockImageView.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
}

//
//  UserProfileTitleFooter.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/7/22.
//

import UIKit

class UserProfileTitleFooter: UICollectionReusableView {
    
    private var sectionAboutTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let buttonImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(systemName: "arrow.forward", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.black)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .white
        addSubviews(sectionAboutTitle, buttonImageView)
        
        NSLayoutConstraint.activate([
            buttonImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            buttonImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            buttonImageView.heightAnchor.constraint(equalToConstant: 20),
            buttonImageView.widthAnchor.constraint(equalToConstant: 20),

            sectionAboutTitle.centerYAnchor.constraint(equalTo: centerYAnchor),
            sectionAboutTitle.trailingAnchor.constraint(equalTo: buttonImageView.leadingAnchor, constant: -5)
        ])
    }
    
    func set(title: String) {
        sectionAboutTitle.text = title
    }
}


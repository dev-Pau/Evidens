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
        label.text = "View all posts"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
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
        backgroundColor = .white
        addSubview(sectionAboutTitle)
        
        NSLayoutConstraint.activate([
            sectionAboutTitle.centerYAnchor.constraint(equalTo: centerYAnchor),
            sectionAboutTitle.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    func set(title: String) {
        sectionAboutTitle.text = title
    }
}


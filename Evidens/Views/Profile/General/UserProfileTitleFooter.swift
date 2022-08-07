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
        label.textAlignment = .center
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
        addSubviews(sectionAboutTitle)
        
        NSLayoutConstraint.activate([
            sectionAboutTitle.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            sectionAboutTitle.leadingAnchor.constraint(equalTo: leadingAnchor),
            sectionAboutTitle.trailingAnchor.constraint(equalTo: trailingAnchor),
            sectionAboutTitle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    func set(title: String) {
        sectionAboutTitle.text = title
    }
}


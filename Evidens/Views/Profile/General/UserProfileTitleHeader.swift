//
//  UserProfileTitleHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/7/22.
//

import UIKit

class UserProfileTitleHeader: UICollectionReusableView {
    
    private var sectionAboutTitle: UILabel = {
        let label = UILabel()
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
            sectionAboutTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            sectionAboutTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
        ])
    }
    
    func set(title: String) {
        sectionAboutTitle.text = title
    }
}

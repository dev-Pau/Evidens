//
//  GroupTitleCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/12/22.
//

import UIKit

class GroupAboutHeader: UICollectionReusableView {
    
    weak var delegate: UserProfileTitleHeaderDelegate?

    var sectionTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
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
        addSubviews(sectionTitle)
        
        NSLayoutConstraint.activate([
            sectionTitle.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            sectionTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            sectionTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
        ])
    }
    
    func set(title: String) {
        sectionTitle.text = title
    }
}

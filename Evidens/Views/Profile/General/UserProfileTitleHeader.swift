//
//  UserProfileTitleHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/7/22.
//

import UIKit

class UserProfileTitleHeader: UICollectionReusableView {
    
    private var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = lightColor
        return view
    }()
    
    private var sectionAboutTitle: UILabel = {
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
        addSubviews(separatorView, sectionAboutTitle)
        
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 10),
            
            sectionAboutTitle.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10),
            sectionAboutTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            sectionAboutTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            sectionAboutTitle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    func set(title: String) {
        sectionAboutTitle.text = title
    }
}

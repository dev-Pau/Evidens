//
//  PostMenuTitleHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 4/8/22.
//

import UIKit

class PostMenuTitleHeader: UICollectionReusableView {
    
    
    private let padding: CGFloat = 10

    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = lightGrayColor
        view.layer.cornerRadius = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .systemFont(ofSize: 18, weight: .semibold)
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
        addSubviews(separator, titleLabel)
        
        NSLayoutConstraint.activate([
            
            separator.centerXAnchor.constraint(equalTo: centerXAnchor),
            separator.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            separator.heightAnchor.constraint(equalToConstant: 5),
            separator.widthAnchor.constraint(equalToConstant: 50),
            
            titleLabel.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
        ])
    }
    
    func set(title: String) {
        titleLabel.text = title
    }
}


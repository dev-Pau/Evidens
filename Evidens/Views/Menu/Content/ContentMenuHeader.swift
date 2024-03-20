//
//  PostMenuHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 11/6/22.
//

import UIKit

class ContentMenuHeader: UICollectionReusableView {

    private let padding: CGFloat = 10
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.addFont(size: 17.0, scaleStyle: .title2, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .tertiarySystemFill
        view.layer.cornerRadius = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let bottomSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubviews(separator, titleLabel, bottomSeparator)
        backgroundColor = .systemBackground
        NSLayoutConstraint.activate([
            separator.centerXAnchor.constraint(equalTo: centerXAnchor),
            separator.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            separator.heightAnchor.constraint(equalToConstant: 5),
            separator.widthAnchor.constraint(equalToConstant: 40),
            
            titleLabel.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            bottomSeparator.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomSeparator.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomSeparator.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomSeparator.heightAnchor.constraint(equalToConstant: 0.4)
        ])
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func set(reference: Reference?) {
        if let reference {
            titleLabel.text = reference.option.message
        }
    }
}

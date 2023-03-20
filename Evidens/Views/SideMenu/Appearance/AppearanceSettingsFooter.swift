//
//  AppearanceSettingsFooter.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/3/23.
//

import UIKit

class AppearanceSettingsFooter: UICollectionReusableView {
    
    private let descriptionAppearanceLabel: UILabel = {
        let label = UILabel()
        label.text = "Set Dark mode to use the Light or Dark selection located in your device Display & Brightness settings."
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .quaternarySystemFill
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
        addSubviews(separatorView, descriptionAppearanceLabel)
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            descriptionAppearanceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            descriptionAppearanceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            descriptionAppearanceLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10)
        ])
    }
}

//
//  MESearchMenuHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 5/4/23.
//

import UIKit

class MESearchMenuHeder: UICollectionReusableView {

    private let padding: CGFloat = 10
    
    var menuTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .label
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.buttonSize = .mini
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 17, weight: .semibold)
        button.configuration?.attributedTitle = AttributedString("Reset", attributes: container)
        button.addTarget(self, action: #selector(handleResetFilters), for: .touchUpInside)
        button.configuration?.baseForegroundColor = primaryColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        view.backgroundColor = .quaternarySystemFill
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
        addSubviews(separator, menuTitle, resetButton, bottomSeparator)

        NSLayoutConstraint.activate([
            separator.centerXAnchor.constraint(equalTo: centerXAnchor),
            separator.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            separator.heightAnchor.constraint(equalToConstant: 5),
            separator.widthAnchor.constraint(equalToConstant: 40),
            
            menuTitle.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 10),
            menuTitle.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            resetButton.topAnchor.constraint(equalTo: separator.bottomAnchor),
            resetButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            bottomSeparator.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomSeparator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -10),
            bottomSeparator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
            bottomSeparator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    @objc func handleResetFilters() {
        
    }
}

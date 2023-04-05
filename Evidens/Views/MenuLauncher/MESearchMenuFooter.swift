//
//  MESearchMenuFooter.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 5/4/23.
//

import UIKit

class MESearchMenuFooter: UICollectionReusableView {

    private lazy var applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 17, weight: .semibold)
        button.configuration?.attributedTitle = AttributedString("Show Results", attributes: container)
        button.addTarget(self, action: #selector(handleShowResults), for: .touchUpInside)
        button.configuration?.cornerStyle = .capsule
        button.isEnabled = false
        button.configuration?.baseBackgroundColor = primaryColor
        button.configuration?.baseForegroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubviews(applyButton)

        NSLayoutConstraint.activate([
            applyButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            applyButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            applyButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            applyButton.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
    
    @objc func handleShowResults() {
        
    }
}

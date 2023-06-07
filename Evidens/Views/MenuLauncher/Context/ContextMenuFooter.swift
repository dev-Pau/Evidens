//
//  ContextMenuFooter.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/4/23.
//

import UIKit

protocol ContextMenuFooterDelegate: AnyObject {
    func didTapCloseMenu()
}

class ContextMenuFooter: UICollectionReusableView {
    
    weak var delegate: ContextMenuFooterDelegate?
    private let padding: CGFloat = 10
    
    private lazy var reportButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .label
        button.configuration?.baseForegroundColor = .systemBackground
        button.configuration?.cornerStyle = .capsule
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 18, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("Got it", attributes: container)
        button.addTarget(self, action: #selector(handleDismissMenu), for: .touchUpInside)
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
        addSubviews(reportButton)
        
        NSLayoutConstraint.activate([
            reportButton.topAnchor.constraint(equalTo: topAnchor),
            reportButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            reportButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            reportButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    func configureWithReference(reference: Reference) {
        if reference.option == .citation {
            var container = AttributeContainer()
            container.font = .systemFont(ofSize: 18, weight: .bold)
            reportButton.configuration?.attributedTitle = AttributedString("Explore Author Citation", attributes: container)
        } else {
            var container = AttributeContainer()
            container.font = .systemFont(ofSize: 18, weight: .bold)
            reportButton.configuration?.attributedTitle = AttributedString("Explore Web Source", attributes: container)
        }
    }

    @objc func handleDismissMenu() {
        delegate?.didTapCloseMenu()
    }
}



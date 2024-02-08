//
//  PageUnavailableView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/2/24.
//

import UIKit

protocol PageUnavailableViewDelegate: AnyObject {
    func didTapPageButton()
}

class PageUnavailableView: UIView {
    
    weak var delegate: PageUnavailableViewDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = AppStrings.Error.available
        label.font = UIFont.addFont(size: 20, scaleStyle: .title2, weight: .bold)
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton(type: .system)
        
        var configuration = UIButton.Configuration.filled()
        configuration.baseForegroundColor = .systemBackground
        configuration.baseBackgroundColor = .label
        configuration.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 18, scaleStyle: .title2, weight: .bold, scales: false)
        configuration.attributedTitle = AttributedString(AppStrings.Miscellaneous.gotIt, attributes: container)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = configuration
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
        translatesAutoresizingMaskIntoConstraints = false
        
        let size: CGFloat = UIDevice.isPad ? 60 : 50

        addSubviews(titleLabel, button)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            
            button.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            button.heightAnchor.constraint(equalToConstant: size),
            button.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    @objc func didTapButton() {
        delegate?.didTapPageButton()
    }
}

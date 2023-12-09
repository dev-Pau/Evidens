//
//  BaseGuidelineButtonFooter.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 9/12/23.
//

import UIKit

protocol BaseGuidelineButtonFooterDelegate: AnyObject {
    func didTapButton()
}

class BaseGuidelineButtonFooter: UICollectionReusableView {
    
    weak var delegate: BaseGuidelineButtonFooterDelegate?
    
    private lazy var guideButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .label
        configuration.baseForegroundColor = .systemBackground
        configuration.cornerStyle = .capsule
        button.configuration = configuration
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
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
        addSubview(guideButton)
        
        NSLayoutConstraint.activate([
            guideButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            guideButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            guideButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            guideButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 18, scaleStyle: .body, weight: .bold, scales: false)
        guideButton.configuration?.attributedTitle = AttributedString(AppStrings.Miscellaneous.gotIt, attributes: container)
    }
    
    @objc func handleTap() {
        delegate?.didTapButton()
    }
}

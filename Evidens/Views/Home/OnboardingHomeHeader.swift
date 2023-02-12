//
//  OnboardingHomeHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 9/2/23.
//

import UIKit

protocol OnboardingHomeHeaderDelegate: AnyObject {
    func didTapHideSetUp()
}

class OnboardingHomeHeader: UICollectionReusableView {
    
    weak var delegate: OnboardingHomeHeaderDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Let's get you set up"
        label.textColor = .label
        label.font = .systemFont(ofSize: 15, weight: .black)
        return label
    }()
    
    lazy var dotsImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "ellipsis")
        button.configuration?.baseForegroundColor = .label
        button.configuration?.buttonSize = .small
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.showsMenuAsPrimaryAction = true
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
        addSubviews(titleLabel, dotsImageButton)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30),
            
            dotsImageButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            dotsImageButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            dotsImageButton.heightAnchor.constraint(equalToConstant: 20),
            dotsImageButton.widthAnchor.constraint(equalToConstant: 20)
        ])
        
        dotsImageButton.menu = addMenuItems()
    }
    
    private func addMenuItems() -> UIMenu {
        let menuItems = UIMenu(children: [
            UIAction(title: "Show less often", handler: { _ in
                self.delegate?.didTapHideSetUp()
            })
        ])
        return menuItems
    }
}

//
//  TopSearchHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/2/23.
//

import UIKit


protocol PrimarySearchHeaderDelegate: AnyObject {
    func didTapSeeAll(_ header: UICollectionReusableView)
}

class PrimarySearchHeader: UICollectionReusableView {
    weak var delegate: PrimarySearchHeaderDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        let font = UIFont.addFont(size: 19.0, scaleStyle: .title3, weight: .heavy)
        label.font = font
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        return label
    }()
    
    private lazy var seeAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.baseForegroundColor = K.Colors.primaryColor
        button.configuration?.contentInsets = .zero
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleSeeAllButtonTap), for: .touchUpInside)
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
        backgroundColor = .systemBackground
        addSubviews(titleLabel, seeAllButton)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: K.Paddings.Content.horizontalPadding),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: K.Paddings.Content.verticalPadding),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -K.Paddings.Content.verticalPadding),
            
            seeAllButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            seeAllButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -K.Paddings.Content.horizontalPadding)
        ])

    }
    
    func configureWith(title: String, linkText: String?) {
        titleLabel.text = title
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 16, scaleStyle: .title3, weight: .medium)
        
        if let linkText = linkText {
            seeAllButton.configuration?.attributedTitle = AttributedString(linkText, attributes: container)
        } else {
            seeAllButton.isHidden = true
        }
    }
    
    @objc func handleSeeAllButtonTap() {
        delegate?.didTapSeeAll(self)
    }
    
    func hideSeeAllButton(_ isHidden: Bool) {
        seeAllButton.isHidden = isHidden
        seeAllButton.isUserInteractionEnabled = isHidden ? false : true
    }
}

//
//  PrimaryProfileHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 9/9/23.
//

import UIKit

class PrimaryProfileHeader: UICollectionReusableView {
    weak var delegate: PrimarySearchHeaderDelegate?
    
    var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = K.Colors.separatorColor
        view.isHidden = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 18.0, scaleStyle: .title3, weight: .heavy)
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
        button.addTarget(self, action: #selector(handleSeeAllTap), for: .touchUpInside)
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
        addSubviews(separatorView, titleLabel, seeAllButton)
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            seeAllButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            seeAllButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }
    
    func configureWith(title: String, linkText: String) {
        titleLabel.text = title
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 15, scaleStyle: .title3, weight: .medium)
        seeAllButton.configuration?.attributedTitle = AttributedString(linkText, attributes: container)
    }
    
    func hideSeparator() {
        separatorView.isHidden = true
    }
    
    @objc func handleSeeAllTap() {
        delegate?.didTapSeeAll(self)
    }
    
    func hideSeeAllButton(_ isHidden: Bool) {
        seeAllButton.isHidden = isHidden
        seeAllButton.isUserInteractionEnabled = !isHidden
        separatorView.isHidden = false
    }
    
    func configureSeeAllButton(isCurrentUser: Bool, isHidden: Bool) {
        if isCurrentUser {
            seeAllButton.isHidden = false
            seeAllButton.isUserInteractionEnabled = true
        } else {
            seeAllButton.isHidden = isHidden
            seeAllButton.isUserInteractionEnabled = !isHidden
            separatorView.isHidden = false
        }
    }
}

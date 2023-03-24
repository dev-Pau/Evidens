//
//  SecondarySearchHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/2/23.
//

import UIKit

class SecondarySearchHeader: UICollectionReusableView {
    weak var delegate: MainSearchHeaderDelegate?
    
    var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .quaternarySystemFill
        view.isHidden = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        return label
    }()
    
    private lazy var seeAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.baseForegroundColor = primaryColor
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
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            seeAllButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            seeAllButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10)
        ])
    }
    
    func configureWith(title: String, linkText: String) {
        titleLabel.text = title
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .medium)
        seeAllButton.configuration?.attributedTitle = AttributedString(linkText, attributes: container)
    }
    
    @objc func handleSeeAllTap() {
        delegate?.didTapSeeAll(self)
    }
    
    func hideSeeAllButton() {
        seeAllButton.isHidden = true
        seeAllButton.isUserInteractionEnabled = false
    }
}

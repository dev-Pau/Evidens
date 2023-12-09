//
//  BaseGuidelineFooter.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/12/23.
//

import UIKit

protocol BaseGuidelineFooterDelegate: AnyObject {
    func didTapGuideline()
}

class BaseGuidelineFooter: UICollectionReusableView {
    
    weak var delegate: BaseGuidelineFooterDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.isUserInteractionEnabled = false
        label.font = UIFont.addFont(size: 13, scaleStyle: .footnote, weight: .regular)
        return label
    }()
    
    private let chevron: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = false
        iv.image = UIImage(systemName: AppStrings.Icons.rightChevron, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        iv.clipsToBounds = true
        iv.contentMode = .center
        return iv
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
        addSubviews(titleLabel, chevron)
        
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        chevron.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleGuidelineTap)))
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -10),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            
            chevron.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            chevron.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -10),
            chevron.heightAnchor.constraint(equalToConstant: 20),
            chevron.widthAnchor.constraint(equalToConstant: 20),
        ])
        
        titleLabel.text = "See case sharing guidelines and best practices"
    }
    
    @objc func handleGuidelineTap() {
        delegate?.didTapGuideline()
    }
}

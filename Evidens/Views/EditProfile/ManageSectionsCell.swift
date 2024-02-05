//
//  File.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 31/7/22.
//

import UIKit


class ManageSectionsCell: UICollectionViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 15, scaleStyle: .largeTitle, weight: .bold)
        label.numberOfLines = 0
        label.text = AppStrings.Sections.title
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let tf = UILabel()
        let label = UILabel()
        label.font = UIFont.addFont(size: 13, scaleStyle: .largeTitle, weight: .regular)
        label.numberOfLines = 0
        label.text = AppStrings.Sections.content
        label.textColor = primaryGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addSectionButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.buttonSize = .mini
        button.configuration?.cornerStyle = .capsule
        
        let size: CGFloat = UIDevice.isPad ? 35 : 30
        
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.rightArrowCircleFill, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.scalePreservingAspectRatio(targetSize: CGSize(width: size, height: size)).withRenderingMode(.alwaysOriginal).withTintColor(primaryColor)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = separatorColor
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
        backgroundColor = .systemBackground
        addSubviews(titleLabel, subtitleLabel, separatorView, addSectionButton)
        
        let size: CGFloat = UIDevice.isPad ? 35 : 30
        
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            
            addSectionButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            addSectionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            addSectionButton.heightAnchor.constraint(equalToConstant: size),
            addSectionButton.widthAnchor.constraint(equalToConstant: size),
            
            titleLabel.centerYAnchor.constraint(equalTo: addSectionButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: addSectionButton.leadingAnchor, constant: -10),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

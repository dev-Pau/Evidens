//
//  ConfigureSectionTitleCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 31/7/22.
//

import UIKit

class SectionCell: UICollectionViewCell {
    
    private let image: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 16.0, scaleStyle: .title3, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        return label
    }()
    
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 14.0, scaleStyle: .title3, weight: .regular)
        label.textColor = K.Colors.primaryGray
        label.numberOfLines = 0
        return label
    }()
    
    private let chevron: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .center
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: AppStrings.Icons.rightChevron, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysTemplate)
        iv.tintColor = K.Colors.separatorColor
        return iv
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = K.Colors.separatorColor
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
        
        addSubviews(image, titleLabel, contentLabel, chevron, separatorView)
        
        let imageSize: CGFloat = UIDevice.isPad ? 30 : 25
        let chevronSize: CGFloat = UIDevice.isPad ? 25 : 20
        
        NSLayoutConstraint.activate([
            
            image.leadingAnchor.constraint(equalTo: leadingAnchor, constant: K.Paddings.Content.horizontalPadding),
            image.centerYAnchor.constraint(equalTo: centerYAnchor),
            image.widthAnchor.constraint(equalToConstant: imageSize),
            image.heightAnchor.constraint(equalToConstant: imageSize),
            
            chevron.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -K.Paddings.Content.horizontalPadding),
            chevron.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: chevronSize),
            chevron.heightAnchor.constraint(equalToConstant: chevronSize),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: K.Paddings.Content.verticalPadding),
            titleLabel.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: K.Paddings.Content.horizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -10),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            contentLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            contentLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -K.Paddings.Content.verticalPadding),
           
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
        ])
    }
    
    func set(section: Section) {
        titleLabel.text = section.title
        image.image = UIImage(systemName: section.image, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(K.Colors.primaryGray)
        contentLabel.text = section.content
    }
}

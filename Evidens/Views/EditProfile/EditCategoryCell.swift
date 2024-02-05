//
//  EditCategoryCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 31/7/22.
//

import UIKit

class EditCategoryCell: UICollectionViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 15, scaleStyle: .largeTitle, weight: .bold)
        label.numberOfLines = 1
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 15, scaleStyle: .largeTitle, weight: .medium)
        label.numberOfLines = 1
        label.textColor = primaryColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let chevronButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.translatesAutoresizingMaskIntoConstraints = false
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
        
        let width: CGFloat = UIDevice.isPad ? 150 : 100
        let buttonSize: CGFloat = UIDevice.isPad ? 20 : 15
        
        addSubviews(titleLabel, subtitleLabel, chevronButton, separatorView)
        
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            titleLabel.widthAnchor.constraint(equalToConstant: width),
            
            chevronButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            chevronButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            chevronButton.widthAnchor.constraint(equalToConstant: buttonSize),
            chevronButton.heightAnchor.constraint(equalToConstant: buttonSize),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10),
            subtitleLabel.trailingAnchor.constraint(equalTo: chevronButton.leadingAnchor, constant: -5)
        ])
    }
    
    func set(title: String, subtitle: String, image: String) {
        let buttonSize: CGFloat = UIDevice.isPad ? 20 : 15
        
        titleLabel.text = title
        subtitleLabel.text = subtitle
        chevronButton.configuration?.image = UIImage(systemName: image, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.tertiaryLabel).scalePreservingAspectRatio(targetSize: CGSize(width: buttonSize, height: buttonSize))
    }
    
    func updateSpeciality(speciality: String) {
        subtitleLabel.text = speciality
    }
}


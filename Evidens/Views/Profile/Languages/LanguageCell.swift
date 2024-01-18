//
//  LanguageCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/9/22.
//

import UIKit

class LanguageCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet {
            button.configuration?.image = UIImage(systemName: isSelected ? AppStrings.Icons.checkmarkCircleFill : AppStrings.Icons.circle, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)).withTintColor(isSelected ? primaryColor : .secondaryLabel)
        }
    }

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.addFont(size: 17, scaleStyle: .title2, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    let button: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.baseForegroundColor = primaryColor
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.circle, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)).withTintColor(.secondaryLabel)
        button.configuration?.cornerStyle = .capsule
        return button
    }()
    
    private var separatorView: UIView = {
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
        
        addSubviews(titleLabel, button, separatorView)

        NSLayoutConstraint.activate([
            
            button.centerYAnchor.constraint(equalTo: centerYAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 13),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -10),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -13),
            
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4)
        ])
    }
    
    func set(kind: LanguageKind) {
        titleLabel.text = kind.name
    }
    
    func set(proficiency: LanguageProficiency) {
        titleLabel.text = proficiency.name
    }
}


//
//  SupportSectionCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/9/22.
//

import UIKit

class SupportSectionCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet {
            selectedOptionButton.configuration?.image = isSelected ? UIImage(systemName: AppStrings.Icons.checkmark, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)).withTintColor(primaryColor) : UIImage(systemName: "")
        }
    }

    let typeTitle: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let selectedOptionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.baseForegroundColor = primaryColor
        button.configuration?.cornerStyle = .capsule
        return button
    }()
    
    private var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var cellContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
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
        
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        
        cellContentView.addSubviews(typeTitle, selectedOptionButton, separatorView)
        cellContentView.backgroundColor = .systemBackground
        NSLayoutConstraint.activate([
            
            selectedOptionButton.centerYAnchor.constraint(equalTo: cellContentView.centerYAnchor),
            selectedOptionButton.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            
            typeTitle.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: 10),
            typeTitle.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            typeTitle.trailingAnchor.constraint(equalTo: selectedOptionButton.leadingAnchor, constant: -10),
            typeTitle.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor, constant: -10),
            
            separatorView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            separatorView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 30),
            separatorView.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor, constant: -1),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4)
        ])
    }
    
    func set(title: Section) {
        typeTitle.text = title.name
    }
    
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        let autoLayoutSize = cellContentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
}


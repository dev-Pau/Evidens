//
//  ClinicalTypeCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 9/7/22.
//

import UIKit

class ClinicalTypeCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet {
            selectedOptionButton.configuration?.image = isSelected ? UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)).withTintColor(primaryColor) : UIImage(systemName: "")
        }
    }

    let typeTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
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
        view.backgroundColor = .quaternarySystemFill
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
        addSubviews(typeTitle, selectedOptionButton, separatorView)
        
        NSLayoutConstraint.activate([
            selectedOptionButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            selectedOptionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            selectedOptionButton.heightAnchor.constraint(equalToConstant: 15),
            selectedOptionButton.widthAnchor.constraint(equalToConstant: 15),
            
            typeTitle.centerYAnchor.constraint(equalTo: centerYAnchor),
            typeTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            typeTitle.trailingAnchor.constraint(equalTo: selectedOptionButton.leadingAnchor, constant: 10),
            typeTitle.heightAnchor.constraint(equalToConstant: 20),
            
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    func set(title: String) {
        typeTitle.text = title
    }
}

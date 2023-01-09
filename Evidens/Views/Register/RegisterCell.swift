//
//  RegisterProfessionCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/7/22.
//

import UIKit

class RegisterCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet {
            selectButton.configuration?.image = isSelected ? UIImage(systemName: "circle.fill")?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)).withTintColor(primaryColor) : UIImage(systemName: "circle")?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)).withTintColor(primaryColor)
        }
    }
    
    let professionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.numberOfLines = 0
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let selectButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "circle")?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)).withTintColor(primaryColor)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
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
        addSubviews(professionLabel, selectButton)
        
        NSLayoutConstraint.activate([
            
            selectButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            selectButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            selectButton.heightAnchor.constraint(equalToConstant: 20),
            selectButton.widthAnchor.constraint(equalToConstant: 20),
            
            professionLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            professionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            professionLabel.trailingAnchor.constraint(equalTo: selectButton.leadingAnchor, constant: -10)
        ])
    }
    
    func set(value: String) {
        professionLabel.text = value
    }
}

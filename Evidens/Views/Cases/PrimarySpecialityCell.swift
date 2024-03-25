//
//  PrimarySpecialityCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 5/7/22.
//

import UIKit

class PrimarySpecialityCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? K.Colors.primaryColor : .systemBackground
            specialityLabel.textColor = isSelected  ? .white : .label
            layer.borderWidth = isSelected ? 0 : 0.4
            layer.borderColor = K.Colors.separatorColor.cgColor
            checkmarkImage.tintColor = isSelected ? .white : .clear
        }
    }
    
    var specialityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 15, scaleStyle: .largeTitle, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.sizeToFit()
        label.contentMode = .bottomLeft
        return label
    }()
    
    let checkmarkImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: AppStrings.Icons.checkmarkCircleFill)
        iv.tintColor = .clear
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        layer.cornerRadius = 10
        layer.borderWidth = 0.4
        layer.borderColor = K.Colors.separatorColor.cgColor
        backgroundColor = .systemBackground
        
        addSubviews(specialityLabel, checkmarkImage)

        NSLayoutConstraint.activate([
            specialityLabel.topAnchor.constraint(equalTo: checkmarkImage.bottomAnchor, constant: 5),
            specialityLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            specialityLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            specialityLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            
            checkmarkImage.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            checkmarkImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            checkmarkImage.heightAnchor.constraint(equalToConstant: 20),
            checkmarkImage.widthAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func set(speciality: Speciality) {
        specialityLabel.text = speciality.name
    }
}

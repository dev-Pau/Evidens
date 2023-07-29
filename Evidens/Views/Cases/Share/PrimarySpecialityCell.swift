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
            backgroundColor = isSelected ? primaryColor : .secondarySystemGroupedBackground
            specialityLabel.textColor = isSelected  ? .white : .label
            layer.borderWidth = isSelected ? 0 : 1.0
            checkmarkImage.tintColor = isSelected ? .white : .secondarySystemGroupedBackground
        }
    }
    
    var specialityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    let checkmarkImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: AppStrings.Icons.checkmarkCircleFill)
        iv.tintColor = .secondarySystemGroupedBackground
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
        layer.borderWidth = 1
        layer.borderColor = UIColor.quaternarySystemFill.cgColor
        backgroundColor = .secondarySystemGroupedBackground
        
        addSubviews(specialityLabel, checkmarkImage)

        NSLayoutConstraint.activate([
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

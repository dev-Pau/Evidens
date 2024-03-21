//
//  EditCaseHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/5/23.
//

import UIKit

class EditCaseHeader: UICollectionReusableView {

    private var specialitiesLabel: UILabel = {
        let label = UILabel()
        label.textColor = K.Colors.primaryGray
        label.font = UIFont.addFont(size: 12, scaleStyle: .largeTitle, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var chevronButton: UIButton = {
        let button = UIButton(type: .system)
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.rightChevron)?.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)).withTintColor(K.Colors.primaryGray)
        return button
    }()
    
    private lazy var editButton: UILabel = {
        let label = UILabel()
        label.text = AppStrings.Miscellaneous.edit
        label.textColor = K.Colors.primaryColor
        label.textAlignment = .right
        label.font = UIFont.addFont(size: 12, scaleStyle: .largeTitle, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubviews(chevronButton, editButton, specialitiesLabel)
        NSLayoutConstraint.activate([
            chevronButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            chevronButton.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            chevronButton.heightAnchor.constraint(equalToConstant: 10),
            chevronButton.widthAnchor.constraint(equalToConstant: 10),
            
            editButton.centerYAnchor.constraint(equalTo: chevronButton.centerYAnchor),
            editButton.trailingAnchor.constraint(equalTo: chevronButton.leadingAnchor, constant: -10),
            editButton.heightAnchor.constraint(equalToConstant: 10),
            editButton.leadingAnchor.constraint(equalTo: specialitiesLabel.trailingAnchor, constant: 10),
        
            specialitiesLabel.centerYAnchor.constraint(equalTo: chevronButton.centerYAnchor),
            specialitiesLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            specialitiesLabel.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
    
    func setTitle(_ text: String) {
        specialitiesLabel.text = text
    }
}

//
//  RegistrationInterestsCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/3/23.
//

import UIKit

class ChoiceCell: UICollectionViewCell {

    override var isSelected: Bool {
        didSet {
            guard isSelectable else { return }
            backgroundColor = isSelected ? K.Colors.primaryColor : .clear
            choiceLabel.textColor = isSelected ? .white : .label
            layer.borderWidth = isSelected ? 0 : 1
        }
    }
    
    var isSelectable: Bool = true
    
    var choiceLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.font = UIFont.addFont(size: 14, scaleStyle: .largeTitle, weight: .bold)
        label.numberOfLines = 1
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .clear
        layer.borderWidth = 1
        layer.borderColor = K.Colors.separatorColor.cgColor
        
        addSubviews(choiceLabel)
        
        NSLayoutConstraint.activate([
            choiceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: K.Paddings.Content.horizontalPadding),
            choiceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -K.Paddings.Content.horizontalPadding),
            choiceLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -K.Paddings.Content.verticalPadding),
            choiceLabel.topAnchor.constraint(equalTo: topAnchor, constant: K.Paddings.Content.verticalPadding)
        ])
    }

    func setText(text: String) {
        choiceLabel.text = text
    }
    
    func set(discipline: Discipline) {
        choiceLabel.text = discipline.name
    }
    
    func set(searchTopic: SearchTopics) {
        choiceLabel.text = searchTopic.title
    }
    
    func set(speciality: Speciality) {
        choiceLabel.text = speciality.name
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
             if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                 layer.borderColor = K.Colors.separatorColor.cgColor
             }
         }
    }
}




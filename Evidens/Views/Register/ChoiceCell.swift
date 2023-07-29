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
            backgroundColor = isSelected ? primaryColor : .clear
            choiceLabel.textColor = isSelected ? .white : .label
        }
    }
    
    var isSelectable: Bool = true
    
    var choiceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.numberOfLines = 0
        label.textColor = .label
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
        layer.cornerRadius = 20
        backgroundColor = .clear
        layer.borderWidth = 1
        layer.borderColor = UIColor.quaternarySystemFill.cgColor
        
        addSubviews(choiceLabel)
        
        NSLayoutConstraint.activate([
            choiceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            choiceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            choiceLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            choiceLabel.topAnchor.constraint(equalTo: topAnchor)
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
             if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                 layer.borderColor = UIColor.quaternarySystemFill.cgColor
             }
         }
    }
}




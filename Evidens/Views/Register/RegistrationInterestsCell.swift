//
//  RegistrationInterestsCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/3/23.
//

import UIKit

class RegistrationInterestsCell: UICollectionViewCell {
    
    //weak var delegate: FilterCasesCellDelegate?
    
    override var isSelected: Bool {
        didSet {
            //layer.borderColor = isSelected ? primaryColor.cgColor : UIColor.quaternarySystemFill.cgColor
            backgroundColor = isSelected ? primaryColor : .clear
            tagsLabel.textColor = isSelected ? .white : .label
        }
    }
    
    var tagsLabel: UILabel = {
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
        
        addSubviews(tagsLabel)
        
        NSLayoutConstraint.activate([
            tagsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            tagsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            tagsLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            tagsLabel.topAnchor.constraint(equalTo: topAnchor)
        ])
    }

    func setText(text: String) {
        tagsLabel.text = text
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
             if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                 // ColorUtils.loadCGColorFromAsset returns cgcolor for color name
                 layer.borderColor = UIColor.quaternarySystemFill.cgColor
             }
         }
    }
    /*
    @objc func handleImageTap() {
        delegate?.didTapFilterImage(self)
    }
     */
}




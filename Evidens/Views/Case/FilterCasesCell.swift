//
//  FilterCasesCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 11/10/22.
//

import UIKit

protocol FilterCasesCellDelegate: AnyObject {
    func didTapFilterImage(_ cell: UICollectionViewCell)
}

class FilterCasesCell: UICollectionViewCell {
    
    weak var delegate: FilterCasesCellDelegate?
    
    override var isSelected: Bool {
        didSet {
            layer.borderColor = isSelected ? primaryColor.cgColor : lightGrayColor.cgColor
            backgroundColor = isSelected ? primaryColor : lightColor
            tagsLabel.textColor = isSelected ? .white : .black
        }

    }
    
    var tagsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .black
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
        layer.cornerRadius = 15
        layer.borderWidth = 1
        layer.borderColor = lightGrayColor.cgColor
        backgroundColor = .quaternarySystemFill
        
        addSubviews(tagsLabel)
        
        NSLayoutConstraint.activate([
            tagsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            tagsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            tagsLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            tagsLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5)
        ])
    }
    
    @objc func handleImageTap() {
        delegate?.didTapFilterImage(self)
    }
}


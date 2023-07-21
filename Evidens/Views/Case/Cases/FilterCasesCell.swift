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
    var changeAppearanceOnSelection: Bool = true
    
    override var isSelected: Bool {
        didSet {
            guard changeAppearanceOnSelection else { return }
            tagsLabel.textColor = self.isSelected ? .white : .label
            tagsLabel.font = .systemFont(ofSize: 14, weight: isSelected ? .semibold : .medium)
        }
    }
    
    var tagsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
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
        backgroundColor = .clear
        
        addSubviews(tagsLabel)
        
        NSLayoutConstraint.activate([
            tagsLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            tagsLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            tagsLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            tagsLabel.topAnchor.constraint(equalTo: topAnchor)
        ])
    }

    func setText(text: String) {
        tagsLabel.text = "  \(text)  "
    }
    
    func set(discipline: Discipline) {
        tagsLabel.text = "  \(discipline.name)  "
    }
    
    @objc func handleImageTap() {
        delegate?.didTapFilterImage(self)
    }
}




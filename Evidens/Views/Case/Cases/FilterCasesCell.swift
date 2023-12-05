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
            titleLabel.textColor = self.isSelected ? .white : .label
            let font = UIFont.addFont(size: 14, scaleStyle: .largeTitle, weight: isSelected ? .semibold : .medium)
            titleLabel.font = font
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 14, scaleStyle: .largeTitle, weight: .medium)
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
        addSubviews(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
    
    func set(text: String) {
        titleLabel.text = "  " + text + "  "
    }

    func set(discipline: Discipline) {
        titleLabel.text = "  \(discipline.name)  "
    }
    
    func set(searchTopic: SearchTopics) {
        titleLabel.text = "  \(searchTopic.title)  "
    }
    
    @objc func handleImageTap() {
        delegate?.didTapFilterImage(self)
    }
}




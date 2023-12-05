//
//  CaseTagExpandedCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 5/12/23.
//

import UIKit

class CaseTagExpandedCell: UICollectionViewCell {
    
    private let tagLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 13.5, scaleStyle: .largeTitle, weight: .semibold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
    private func configure() {
        backgroundColor = caseColor
        
        addSubview(tagLabel)
        
        let insets = UIFont.addFont(size: 13.5, scaleStyle: .largeTitle, weight: .semibold).lineHeight / 2

        NSLayoutConstraint.activate([
            tagLabel.topAnchor.constraint(equalTo: topAnchor, constant: insets),
            tagLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets),
            tagLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets),
            tagLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets)
        ])
    }
    
    func set(tag: String) {
        tagLabel.text = tag
    }
}

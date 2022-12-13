//
//  GroupTitleCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/12/22.
//

import UIKit
import Firebase

class GroupDetailsCell: UICollectionViewCell {
    
    private let groupTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let groupLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = grayColor
        label.numberOfLines = 0
        return label
    }()
    
    private let groupCreationDateLabel: UILabel = {
        let label = UILabel()
        label.text = "Creation date"
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let groupCreationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = grayColor
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
        addSubviews(groupTitleLabel, groupLabel, groupCreationDateLabel, groupCreationLabel)
        NSLayoutConstraint.activate([
            groupTitleLabel.topAnchor.constraint(equalTo: topAnchor),
            groupTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            groupTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            groupLabel.topAnchor.constraint(equalTo: groupTitleLabel.bottomAnchor),
            groupLabel.leadingAnchor.constraint(equalTo: groupTitleLabel.leadingAnchor),
            groupLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            groupCreationDateLabel.topAnchor.constraint(equalTo: groupLabel.bottomAnchor, constant: 5),
            groupCreationDateLabel.leadingAnchor.constraint(equalTo: groupTitleLabel.leadingAnchor),
            
            groupCreationLabel.topAnchor.constraint(equalTo: groupCreationDateLabel.bottomAnchor),
            groupCreationLabel.leadingAnchor.constraint(equalTo: groupTitleLabel.leadingAnchor),
            groupCreationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            groupCreationLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])
    }
    
    func set(title: String, creationDate: Timestamp) {
        groupLabel.text = title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        groupCreationLabel.text = dateFormatter.string(from: creationDate.dateValue())
    }
}

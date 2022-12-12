//
//  GroupSizeCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/12/22.
//

import UIKit

class GroupSizeCell: UICollectionViewCell {
    
    private let cellContentView = UIView()
    
    private let groupSizeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .black
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
        addSubview(cellContentView)
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        cellContentView.addSubview(groupSizeLabel)
        
        NSLayoutConstraint.activate([
            groupSizeLabel.topAnchor.constraint(equalTo: cellContentView.topAnchor),
            groupSizeLabel.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 5),
            groupSizeLabel.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            groupSizeLabel.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor)
        ])
    }
    
    func set(members: String) {
        groupSizeLabel.text = members
    }
}

//
//  SearchToolbarCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/3/23.
//

import UIKit

protocol SearchToolbarCellDelegate: AnyObject {
    func didRestoreMenu()
    func didSelectSearchTopic(_ searchTopic: SearchTopics)
    
}

class SearchToolbarCell: UICollectionViewCell {
    weak var delegate: SearchToolbarCellDelegate?
    private let searchDataSource = SearchTopics.allCases
    
    var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.numberOfLines = 0
        label.isUserInteractionEnabled = false
        label.textColor = .white
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
        backgroundColor = primaryColor
        addSubviews(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
        ])
    }
    
    func set(discipline: Discipline) {
        label.text = "   " + discipline.name + "   "
    }
    
    func set(searchTopic: SearchTopics) {
        label.text = "   " + searchTopic.title + "   "
    }
}



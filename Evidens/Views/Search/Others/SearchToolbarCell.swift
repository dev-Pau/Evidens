//
//  SearchToolbarCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/3/23.
//

import UIKit

protocol SearchToolbarCellDelegate: AnyObject {
    func didRestoreMenu()
    func didSelectSearchTopic(_ topic: String)
    func didSelectSearchCategory(_ category: SearchTopics)
}

class SearchToolbarCell: UICollectionViewCell {
    weak var delegate: SearchToolbarCellDelegate?
    private let searchDataSource = SearchTopics.allCases
    
    var tagsLabel: UILabel = {
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
        addSubviews(tagsLabel)
        NSLayoutConstraint.activate([
            tagsLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            tagsLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            tagsLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            tagsLabel.topAnchor.constraint(equalTo: topAnchor),
        ])
    }
    
    func setText(text: String) {
        tagsLabel.text = "     \(text)     "
    }
}



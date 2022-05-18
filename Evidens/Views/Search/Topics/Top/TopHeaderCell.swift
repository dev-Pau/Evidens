//
//  TopHeaderCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/5/22.
//

import UIKit

class TopHeaderCell: UITableViewHeaderFooterView {
    
    //MARK: - Properties
    
    
    private let recentSearchesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.text = "People"
        return label
    }()

    //MARK: - Lifecycle
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        
        addSubview(recentSearchesLabel)
        recentSearchesLabel.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Actions
    @objc func clearButtonPressed() {
       
    }
}

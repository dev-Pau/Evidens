//
//  RecentHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/5/22.
//

import UIKit

protocol RecentHeaderCellDelegate: AnyObject {
    func headerPressed()
}

class RecentHeader: UITableViewHeaderFooterView {
    
    //MARK: - Properties
    private let recentSearchesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.text = "Recent searches"
        return label
    }()
    
    private lazy var clearButton: UIButton = {
        let button = UIButton()
        button.configuration = .plain()
        button.configuration?.baseBackgroundColor = .white
        
        button.configuration?.baseForegroundColor = blackColor
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("Clear", attributes: container)
        button.addTarget(self, action: #selector(clearButtonPressed), for: .touchUpInside)
        return button
    }()

    //MARK: - Lifecycle
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        
        addSubview(recentSearchesLabel)
        recentSearchesLabel.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        
        addSubview(clearButton)
        clearButton.centerY(inView: self)
        clearButton.anchor(right: rightAnchor, paddingRight: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Actions
    @objc func clearButtonPressed() {
        print("clear button pressed")
    }
}

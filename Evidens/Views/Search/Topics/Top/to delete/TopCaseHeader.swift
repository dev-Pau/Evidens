//
//  TopCasesHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/5/22.
//

import UIKit

class TopCaseHeader: UITableViewHeaderFooterView {
    
    //MARK: - Properties
    
    private let casesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.text = "Cases"
        label.textColor = .label
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemBackground
        addSubview(casesLabel)
        casesLabel.centerY(inView: self)
        casesLabel.anchor(left: leftAnchor, paddingLeft: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

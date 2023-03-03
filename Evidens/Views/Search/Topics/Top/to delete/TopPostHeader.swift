//
//  TopPostHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/5/22.
//

import UIKit

class TopPostHeader: UITableViewHeaderFooterView {
    
    private let postLabel: UILabel = {
       let label = UILabel()
        label.text = "Posts"
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    
    //MARK: - Lifecycle
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemBackground
        addSubview(postLabel)
        postLabel.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

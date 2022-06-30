//
//  PostPollCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/6/22.
//

import UIKit

class PostPollCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .white
    }
    
    
}

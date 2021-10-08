//
//  RegistrationEmailCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 8/10/21.
//

import UIKit

class RegistrationViewCell: UITableViewCell {
    
    // MARK: - Properties
    static let identifier = "RegistrationViewCell"
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .orange
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//
//  RegisterTypeCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/1/22.
//

import UIKit

class RegisterTypeCell: UITableViewCell {
    
    //MARK: - Properties
    
    let notificationTypeImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.tintColor = UIColor(rgb: 0x79CBBF)
        return iv
    }()
    
    let userTypeTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()

    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        addSubview(notificationTypeImageView)
        notificationTypeImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 5)
        
        addSubview(userTypeTextLabel)
        userTypeTextLabel.centerY(inView: self)
        userTypeTextLabel.centerX(inView: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Actions

  
    //MARK: - Helpers
    
    private func configure() {
        backgroundColor = .white
    }
}

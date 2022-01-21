//
//  RegisterUserTypeCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/1/22.
//

import UIKit

class RegisterUserTypeCell: UICollectionViewCell {
    
    // MARK: - Properties


    let userDetailedLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Lifecycle
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(rgb: 0x79CBBF)
        addSubview(userDetailedLabel)
        userDetailedLabel.centerY(inView: self)
        userDetailedLabel.centerX(inView: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
   
    
    // MARK: - Helpers
    
}

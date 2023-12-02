//
//  CustomLabel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/10/21.
//

import UIKit

class PrimaryLabel: UILabel {
    
    init(placeholder: String) {
        super.init(frame: .zero)
        
        textColor = .label
        numberOfLines = 0
        translatesAutoresizingMaskIntoConstraints = false
        
        font = UIFont.addFont(size: 28, scaleStyle: .title1, weight: .heavy)

        text = placeholder
    }
    
    func setPlaceholder(_ placeholder: String) {
        text = placeholder
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

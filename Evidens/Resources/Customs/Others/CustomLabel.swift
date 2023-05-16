//
//  CustomLabel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/10/21.
//

import UIKit

class CustomLabel: UILabel {
    
    init(placeholder: String) {
        super.init(frame: .zero)
        text = placeholder
        font = .systemFont(ofSize: 35, weight: .heavy)
        //font = UIFont(name: "Raleway-Black", size: 35)
        textColor = .label
        numberOfLines = 0
        //sizeToFit()
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

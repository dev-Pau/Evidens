//
//  CustomTextField.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/10/21.
//

import UIKit

class CustomTextField: UITextField {
    
    init(placeholder: String) {
        super.init(frame: .zero)
         
        let spacer = UIView()
        spacer.setDimensions(height: 40, width: 10)
        leftView = spacer
        leftViewMode = .always
        borderStyle = .roundedRect
        textColor = .label
        translatesAutoresizingMaskIntoConstraints = false
        keyboardAppearance = .default
        keyboardType = .emailAddress
        autocorrectionType = .no
        backgroundColor = .tertiarySystemFill
        layer.cornerRadius = 5
        layer.borderColor = UIColor.systemBackground.cgColor
        layer.borderWidth = 1.0
        //setDimensions(height: 40, width: 100
        self.placeholder = placeholder
        //attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: UIColor(white: 0.2, alpha: 0.7)])
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  METextView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/6/22.
//

import UIKit

class METextField: UITextField {
    
    init(placeholder: String, withSpacer: Bool) {
        super.init(frame: .zero)
        
        if withSpacer {
            let spacer = UIView()
            spacer.setDimensions(height: 40, width: 10)
            leftView = spacer
        }
        
        leftViewMode = .always
        borderStyle = .roundedRect
        textColor = .black
        keyboardAppearance = .light
        keyboardType = .emailAddress
        autocorrectionType = .no
        backgroundColor = lightColor
        layer.cornerRadius = 5
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1.0
        attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: UIColor(white: 0.2, alpha: 0.7)])
        clearButtonMode = .whileEditing
    }
    
    init(attrPlaceholder: NSMutableAttributedString, withSpacer: Bool) {
        super.init(frame: .zero)
        
        if withSpacer {
            let spacer = UIView()
            spacer.setDimensions(height: 40, width: 10)
            leftView = spacer
        }
        
        leftViewMode = .always
        borderStyle = .roundedRect
        textColor = .black
        keyboardAppearance = .light
        keyboardType = .default
        autocorrectionType = .no
        backgroundColor = lightColor
        layer.cornerRadius = 5
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1.0
        attributedPlaceholder = attrPlaceholder
        //ttributedPlaceholder = NSAttributedString(string: attributedPlaceholder, attributes: [.foregroundColor: UIColor(white: 0.2, alpha: 0.7)])
        clearButtonMode = .always
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

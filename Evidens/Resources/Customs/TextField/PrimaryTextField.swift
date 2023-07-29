//
//  METextView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/6/22.
//

import UIKit

class PrimaryTextField: UITextField {
    
    init(placeholder: String) {
        super.init(frame: .zero)
        leftViewMode = .always
        textColor = .label
        keyboardAppearance = .default
        keyboardType = .default
        autocorrectionType = .no
        backgroundColor = .systemBackground
        clearButtonMode = .whileEditing
        self.placeholder = placeholder
    }
    
    init(placeholder: String, withSpacer: Bool) {
        super.init(frame: .zero)
        
        leftViewMode = .always
        borderStyle = .roundedRect
        textColor = .label
        keyboardAppearance = .default
        keyboardType = .emailAddress
        autocorrectionType = .no
        backgroundColor = .quaternarySystemFill
        layer.cornerRadius = 5
        layer.borderColor = UIColor.systemBackground.cgColor
        layer.borderWidth = 1.0
        attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: UIColor.secondaryLabel])
        clearButtonMode = .whileEditing
    }
    
    init(attrPlaceholder: NSMutableAttributedString, withSpacer: Bool) {
        super.init(frame: .zero)
        
        leftViewMode = .always
        borderStyle = .roundedRect
        textColor = .label
        keyboardAppearance = .default
        keyboardType = .default
        autocorrectionType = .no
        backgroundColor = .quaternarySystemFill
        layer.cornerRadius = 5
        layer.borderColor = UIColor.systemBackground.cgColor
        layer.borderWidth = 1.0
        attributedPlaceholder = attrPlaceholder
        //ttributedPlaceholder = NSAttributedString(string: attributedPlaceholder, attributes: [.foregroundColor: UIColor(white: 0.2, alpha: 0.7)])
        clearButtonMode = .always
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
             if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                 // ColorUtils.loadCGColorFromAsset returns cgcolor for color name
                layer.borderColor = UIColor.systemBackground.cgColor
             }
         }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

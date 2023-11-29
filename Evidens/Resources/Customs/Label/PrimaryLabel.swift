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
        
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title1)
        let heavyFontDescriptor = fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.traits: [
                UIFontDescriptor.TraitKey.weight: UIFont.Weight.heavy.rawValue
            ]
        ])
        
        font = UIFont(descriptor: heavyFontDescriptor, size: 0)

        text = placeholder
    }
    
    func setPlaceholder(_ placeholder: String) {
        text = placeholder
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

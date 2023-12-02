//
//  UIFont+Ext.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 30/11/23.
//

import UIKit

extension UIFont {
    
    static func addFont(size: CGFloat, scaleStyle: UIFont.TextStyle, weight: UIFont.Weight, scales: Bool = true) -> UIFont {
        guard scales else {
            return UIFont.systemFont(ofSize: size, weight: weight)
        }
        
        let fontMetrics = UIFontMetrics(forTextStyle: scaleStyle)
        let scaledFont = fontMetrics.scaledValue(for: size)
        
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: scaleStyle)
        let weightFontDescriptor = fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.traits: [
                UIFontDescriptor.TraitKey.weight: weight.rawValue
            ]
        ])
        
        return UIFont(descriptor: weightFontDescriptor, size: scaledFont)
    }
}

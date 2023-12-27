//
//  UIFont+Ext.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 30/11/23.
//

import UIKit

/// An extension of UIFont.
extension UIFont {
    
    /// Creates a UIFont with a specified size, text style, and weight, considering dynamic type scaling.
    /// - Parameters:
    ///   - size: The font size.
    ///   - scaleStyle: The UIFont.TextStyle to determine the scaling behavior.
    ///   - weight: The desired weight of the font.
    ///   - scales: A boolean flag indicating whether dynamic type scaling should be applied. Default is true.
    /// - Returns: A UIFont instance with the specified size, text style, and weight.
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

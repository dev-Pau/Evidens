//
//  UIColor+Ext.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/6/23.
//

import UIKit

/// An extension of UIColor.
extension UIColor {
    
    /// Interpolates between two colors based on the progress value.
    ///
    /// - Parameters:
    ///   - startColor: The starting color.
    ///   - endColor: The ending color.
    ///   - progress: The progress value between 0 and 1.
    ///
    /// - Returns: The interpolated color.
    func interpolateColor(from startColor: UIColor, to endColor: UIColor, progress: CGFloat) -> UIColor {
        var startRed: CGFloat = 0.0, startGreen: CGFloat = 0.0, startBlue: CGFloat = 0.0, startAlpha: CGFloat = 0.0
        var endRed: CGFloat = 0.0, endGreen: CGFloat = 0.0, endBlue: CGFloat = 0.0, endAlpha: CGFloat = 0.0
        
        startColor.getRed(&startRed, green: &startGreen, blue: &startBlue, alpha: &startAlpha)
        endColor.getRed(&endRed, green: &endGreen, blue: &endBlue, alpha: &endAlpha)
        
        let interpolatedRed = startRed + (endRed - startRed) * progress
        let interpolatedGreen = startGreen + (endGreen - startGreen) * progress
        let interpolatedBlue = startBlue + (endBlue - startBlue) * progress
        let interpolatedAlpha = startAlpha + (endAlpha - startAlpha) * progress
        
        return UIColor(red: interpolatedRed, green: interpolatedGreen, blue: interpolatedBlue, alpha: interpolatedAlpha)
    }
}

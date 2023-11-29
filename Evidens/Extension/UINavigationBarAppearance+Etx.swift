//
//  UINavigationBarAppearance+Etx.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/8/23.
//

import UIKit

extension UINavigationBarAppearance {
    
    static func primaryAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.setBackIndicatorImage(UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), transitionMaskImage: UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label))

        let barButtonItemAppearance = UIBarButtonItemAppearance()
        barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        appearance.backButtonAppearance = barButtonItemAppearance
        
        appearance.shadowColor = separatorColor
        
        
        let customFontSize: CGFloat = 17
        let fontMetrics = UIFontMetrics(forTextStyle: .headline)
        let scaledFontSize = fontMetrics.scaledValue(for: customFontSize)
        
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .headline)
        let heavyFontDescriptor = fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.traits: [
                UIFontDescriptor.TraitKey.weight: UIFont.Weight.heavy.rawValue
            ]
        ])
        
        let font = UIFont(descriptor: heavyFontDescriptor, size: scaledFontSize)
        
        appearance.titleTextAttributes = [.font: font]

        
        return appearance
    }
    
    static func secondaryAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.setBackIndicatorImage(UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), transitionMaskImage: UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label))
        
        let barButtonItemAppearance = UIBarButtonItemAppearance()
        barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        appearance.backButtonAppearance = barButtonItemAppearance
        
        appearance.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 17, weight: .heavy)]
        
        appearance.shadowImage = nil
        appearance.shadowColor = .clear
        return appearance
    }
    
    static func profileAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.setBackIndicatorImage(UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), transitionMaskImage: UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label))
        appearance.configureWithOpaqueBackground()
        
        let barButtonItemAppearance = UIBarButtonItemAppearance()
        barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        appearance.backButtonAppearance = barButtonItemAppearance
        appearance.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 17, weight: .heavy)]
        appearance.shadowColor = .clear
        appearance.shadowImage = nil
        
        return appearance
    }
    
}

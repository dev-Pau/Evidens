//
//  UINavigationBarAppearance+Etx.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/8/23.
//

import UIKit

/// An extension of UINavigationBarAppearance.
extension UINavigationBarAppearance {
    
    /// Returns a customized appearance configuration for the primary navigation bar.
    /// - Returns: A configured `UINavigationBarAppearance` instance for the primary navigation bar.
    static func primaryAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.setBackIndicatorImage(UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), transitionMaskImage: UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label))

        let barButtonItemAppearance = UIBarButtonItemAppearance()
        barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        appearance.backButtonAppearance = barButtonItemAppearance
        
        appearance.shadowColor = K.Colors.separatorColor
        
        let font = UIFont.addFont(size: 17, scaleStyle: .title3, weight: .heavy)

        appearance.titleTextAttributes = [.font: font]

        return appearance
    }
    
    /// Returns a customized appearance configuration for the secondary navigation bar.
    /// - Returns: A configured `UINavigationBarAppearance` instance for the secondary navigation bar.
    static func secondaryAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.setBackIndicatorImage(UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), transitionMaskImage: UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label))
        
        let barButtonItemAppearance = UIBarButtonItemAppearance()
        barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        appearance.backButtonAppearance = barButtonItemAppearance
        
        let font = UIFont.addFont(size: 17, scaleStyle: .body, weight: .heavy)
        
        appearance.titleTextAttributes = [.font: font]
        
        appearance.shadowImage = nil
        appearance.shadowColor = .clear
        return appearance
    }
    
    /// Returns a customized appearance configuration for the profile navigation bar.
    /// - Returns: A configured `UINavigationBarAppearance` instance for the profile navigation bar.
    static func profileAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.setBackIndicatorImage(UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), transitionMaskImage: UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label))
        appearance.configureWithOpaqueBackground()
        
        let font = UIFont.addFont(size: 17, scaleStyle: .body, weight: .heavy)
        
        let barButtonItemAppearance = UIBarButtonItemAppearance()
        barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        appearance.backButtonAppearance = barButtonItemAppearance
        appearance.titleTextAttributes = [.font: font]
        appearance.shadowColor = .clear
        appearance.shadowImage = nil
        
        return appearance
    }
    
    /// Returns a customized appearance configuration for the primary navigation bar.
    /// - Returns: A configured `UINavigationBarAppearance` instance for the primary navigation bar.
    static func colorAppearance(withColor color: UIColor) -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.setBackIndicatorImage(UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), transitionMaskImage: UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label))
        
        let barButtonItemAppearance = UIBarButtonItemAppearance()
        barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        appearance.backButtonAppearance = barButtonItemAppearance
        
        let font = UIFont.addFont(size: 17, scaleStyle: .body, weight: .heavy)
        
        appearance.titleTextAttributes = [.font: font]
        
        appearance.shadowImage = nil
        appearance.shadowColor = .clear
        
        appearance.backgroundColor = K.Colors.primaryColor
        return appearance
    }
    
    /// Returns a customized appearance configuration for the secondary navigation bar.
    /// - Returns: A configured `UINavigationBarAppearance` instance for the secondary navigation bar.
    static func contentAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()

        appearance.setBackIndicatorImage(UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), transitionMaskImage: UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label))
        
        let barButtonItemAppearance = UIBarButtonItemAppearance()
        barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        appearance.backButtonAppearance = barButtonItemAppearance
        
        let font = UIFont.addFont(size: 17, scaleStyle: .body, weight: .heavy)
        
        appearance.titleTextAttributes = [.font: font]
        
        appearance.shadowImage = nil
        appearance.shadowColor = K.Colors.separatorColor
        return appearance
    }
}

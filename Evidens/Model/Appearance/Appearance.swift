//
//  Appearance.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/3/23.
//

import UIKit

/// The model for the Appearance.
struct Appearance {
    
    /// An enum mapping all the current appearance themes.
    enum Theme: String, CaseIterable {
        case dark = "Dark mode"
        case system = "Use device settings"
        case light = "Light mode"
    }
}

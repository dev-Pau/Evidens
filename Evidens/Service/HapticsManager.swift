//
//  HapticsManager.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 28/8/23.
//

import UIKit

/// A singleton gateway service used to interface with Core Haptics.
struct HapticsManager {
    
    static let shared = HapticsManager()
    
    /// Triggers a light haptic that's generally used for generic button taps.
    func triggerLightImpact() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    /// Triggers an error haptic.
    func triggerErrorHaptic() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    
    /// Triggers a warning haptic that's generally used  when a user copies content.
    func triggerWarningHaptic() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}

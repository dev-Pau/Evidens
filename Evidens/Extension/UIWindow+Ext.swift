//
//  UIWindow+Ext.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/3/24.
//

import UIKit

extension UIWindow {
    
    static var visibleScreenWidth: CGFloat {
        
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            return window.frame.width
        }
        return UIScreen.main.bounds.width
    }
    
    static var visibleScreenHeight: CGFloat {
            if let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
               let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                return window.frame.height
            }
            return UIScreen.main.bounds.height
        }
        
        static var visibleScreenBounds: CGRect {
            if let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
               let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                return window.bounds
            }
            return UIScreen.main.bounds
        }
}

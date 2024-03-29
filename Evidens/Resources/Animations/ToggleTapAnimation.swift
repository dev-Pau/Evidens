//
//  CustomHeartAnimation.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/6/22.
//

import Foundation
import UIKit

final class ToggleTapAnimation {
    
    static let shared = ToggleTapAnimation()
    
    private init() {}
    
    func animate(_ button: UIButton) {
        button.transform = CGAffineTransform(translationX: 0, y: 0)
        HapticsManager.shared.triggerLightImpact()
     
        UIView.animate(withDuration: 0.1) { [weak self] in
            guard let _ = self else { return }
            button.transform = button.transform.scaledBy(x: 0.8, y: 0.8)
        } completion: { _ in
            UIView.animate(withDuration: 0.1) { [weak self] in
                guard let _ = self else { return }
                button.transform = CGAffineTransform.identity
            }
        }
    }
}

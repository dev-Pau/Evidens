//
//  ContentButton.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/3/24.
//

import UIKit

class ContentButton: UIButton {
    
    private var isAnimating: Bool = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if UIDevice.isPad { animateBounce(scale: 0.7) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    }
    
    private func animateBounce(scale: CGFloat) {
        guard !isAnimating else { return }
        isAnimating = true
        
        let scale: CGFloat = isHighlighted ? 0.7 : 1.0
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: [.curveEaseInOut]) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.transform = CGAffineTransform(scaleX: scale, y: scale)
        } completion: { [weak self] _ in
            guard let _ = self else { return }
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: [.curveEaseOut]) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.transform = CGAffineTransform.identity
            } completion: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.isAnimating = false
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

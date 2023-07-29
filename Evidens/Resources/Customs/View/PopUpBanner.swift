//
//  METopPopupView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/8/22.
//

import UIKit

class PopUpBanner: UIView {
    
    private var popUpKind: PopUpKind
    
    private var title: String
    private var image: String
    private var userDidPanPopup: Bool = false
    
    private var popupView = PopUpView(title: "", image: "", popUpKind: .regular)

    private var timer: Timer?

    init(title: String, image: String, popUpKind: PopUpKind) {
        self.title = title
        self.image = image
        self.popUpKind = popUpKind
        super.init(frame: .zero)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 10
        clipsToBounds = false
    }
    
    func showTopPopup(inView view: UIView) {
        configurePopup(in: view)
        isUserInteractionEnabled = true
    }
    
    func handleDismissPopup(view: PopUpView) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 1, options: .curveEaseOut) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.frame = CGRect(x: 10, y: -55, width: UIScreen.main.bounds.width - 20, height: 50)
            view.frame = strongSelf.frame
        } completion: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.timer!.invalidate()
        }
    }
    
    
    func configurePopup(in view: UIView) {
        let blurEffect = UIBlurEffect(style: .prominent)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        popupView = PopUpView(title: title, image: image, popUpKind: popUpKind)
        
        timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.fireTimer), userInfo: popupView, repeats: false)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.addSubview(self)
            window.addSubview(popupView)
            popupView.insertSubview(blurView, at: 0)
        }
        
        frame = CGRect(x: 10, y: -55, width: UIScreen.main.bounds.width - 20, height: 50)
        popupView.frame = frame
        blurView.frame = popupView.bounds
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 10).cgPath
        blurView.layer.mask = shapeLayer

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.alpha = 1
            strongSelf.frame = CGRect(x: 10, y: 55, width: UIScreen.main.bounds.width - 20, height: 50)
            strongSelf.popupView.frame = strongSelf.frame
            
        })
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        popupView.addGestureRecognizer(pan)
    }
    
    @objc func fireTimer() {
        guard let timer = timer, let popView = timer.userInfo as? PopUpView else {
            return
        }
        handleDismissPopup(view: popView)
    }
    
    @objc func handlePan(sender: UIPanGestureRecognizer) {
        guard let timer = timer else { return }
        userDidPanPopup = true
        timer.invalidate()
        
        let translation = sender.translation(in: popupView)
        let velocity = sender.velocity(in: popupView)
        
        frame.origin = CGPoint(x: 10, y: 55 + translation.y * 0.3)
        popupView.frame = frame
        
        if sender.state == .ended {

            if abs(velocity.y) > 700 {
                UIView.animate(withDuration: 0.2) { [weak self] in
                    guard let strongSelf = self else { return }
                    if velocity.y < 0 {
                        strongSelf.frame.origin = CGPoint(x: strongSelf.frame.origin.x, y: -55)
                        strongSelf.popupView.frame = strongSelf.frame
                        
                    } else {
                        strongSelf.frame.origin = CGPoint(x: strongSelf.frame.origin.x, y: 55)
                        strongSelf.popupView.frame = strongSelf.frame
                        strongSelf.timer = Timer.scheduledTimer(timeInterval: 4, target: strongSelf, selector: #selector(strongSelf.fireTimer), userInfo: strongSelf.popupView, repeats: false)
                    }
                }
            } else {
                UIView.animate(withDuration: 0.3) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.frame.origin = CGPoint(x: strongSelf.frame.origin.x, y: 55)
                    strongSelf.popupView.frame = strongSelf.frame
                    strongSelf.timer = Timer.scheduledTimer(timeInterval: 4, target: strongSelf, selector: #selector(strongSelf.fireTimer), userInfo: strongSelf.popupView, repeats: false)
                }
            }
        }
    }
}

//
//  METopPopupView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/8/22.
//

import UIKit


enum PopUpType {
    case regular
    case destructive
}

class METopPopupView: UIView {
    
    private var popUpType: PopUpType
    
    private var title: String
    private var image: String
    private var userDidPanPopup: Bool = false
    
    private var popupView = PopupView(title: "", image: "", popUpType: .regular)
    
    
    private var timer: Timer?

    init(title: String, image: String, popUpType: PopUpType) {
        self.title = title
        self.image = image
        self.popUpType = popUpType
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
    
    func handleDismissPopup(view: PopupView) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.frame = CGRect(x: 10, y: -55, width: UIScreen.main.bounds.width - 20, height: 50)
            view.frame = self.frame
        } completion: { _ in
            self.timer!.invalidate()
        }
    }
    
    
    func configurePopup(in view: UIView) {
        let blurEffect = UIBlurEffect(style: .prominent)
        // 3
        let blurView = UIVisualEffectView(effect: blurEffect)
        //blurView.layer.cornerRadius = 10
        //blurView.clipsToBounds = true
        // 4
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        popupView = PopupView(title: title, image: image, popUpType: popUpType)
        
        timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.fireTimer), userInfo: popupView, repeats: false)
        
        if let window = UIApplication.shared.keyWindow {
            //window.addSubview(blackBackgroundView)
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
        
        
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.alpha = 1
            self.frame = CGRect(x: 10, y: 55, width: UIScreen.main.bounds.width - 20, height: 50)
            self.popupView.frame = self.frame
            
        })
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        popupView.addGestureRecognizer(pan)
    }
    
    @objc func fireTimer() {
        guard let timer = timer, let popView = timer.userInfo as? PopupView else {
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

                UIView.animate(withDuration: 0.2) {
                    if velocity.y < 0 {
                        // Hide menu
                        self.frame.origin = CGPoint(x: self.frame.origin.x, y: -55)
                        self.popupView.frame = self.frame
                        
                    } else {
                        // Go back to origin
                        self.frame.origin = CGPoint(x: self.frame.origin.x, y: 55)
                        self.popupView.frame = self.frame
                        self.timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.fireTimer), userInfo: self.popupView, repeats: false)
                    }
                }
            } else {
                // Go to initial position
                UIView.animate(withDuration: 0.3) {
                    self.frame.origin = CGPoint(x: self.frame.origin.x, y: 55)
                    self.popupView.frame = self.frame
                    self.timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.fireTimer), userInfo: self.popupView, repeats: false)
                }
            }
        }
    }
}

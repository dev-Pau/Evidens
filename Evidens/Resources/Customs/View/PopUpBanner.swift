//
//  METopPopupView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/8/22.
//

import UIKit

class PopUpBanner: UIView {
    
    private var popUpKind: PopUpKind
    
    private var bottomPopUpAnchor: NSLayoutConstraint!
    
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
        
        layer.borderWidth = 0.4
        layer.borderColor = UIColor.link.cgColor
        
        layer.masksToBounds = false
        layer.shadowColor = primaryGray.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.cornerRadius = 12

        clipsToBounds = false
        backgroundColor = popupColor
    }
    
    func showTopPopup(inView view: UIView) {
        configurePopup(in: view)
        isUserInteractionEnabled = true
    }
    
    func handleDismissPopup(view: PopUpView) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 1, options: .curveEaseOut) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.bottomPopUpAnchor.constant = 0
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.layoutIfNeeded()
            }

        } completion: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.timer!.invalidate()
            strongSelf.removeFromSuperview()
            strongSelf.popupView.removeFromSuperview()
        }
    }
    
    func configurePopup(in view: UIView) {
        popupView = PopUpView(title: title, image: image, popUpKind: popUpKind)
        
        timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.fireTimer), userInfo: popupView, repeats: false)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.addSubview(self)
            window.addSubview(popupView)
            bottomPopUpAnchor = self.bottomAnchor.constraint(equalTo: window.topAnchor)
            
            NSLayoutConstraint.activate([
                bottomPopUpAnchor,
                leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 10),
                trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -10),
                
                popupView.topAnchor.constraint(equalTo: topAnchor),
                popupView.leadingAnchor.constraint(equalTo: leadingAnchor),
                popupView.trailingAnchor.constraint(equalTo: trailingAnchor),
                popupView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        popupView.addGestureRecognizer(pan)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let _ = self else { return }
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [weak self] in
                guard let strongSelf = self else { return }

                strongSelf.bottomPopUpAnchor.constant = strongSelf.popupView.frame.height + 60
                
                strongSelf.layer.shadowPath = UIBezierPath(roundedRect: strongSelf.bounds, cornerRadius: strongSelf.layer.cornerRadius).cgPath
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.layoutIfNeeded()
                }
            })
        }
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
        
        bottomPopUpAnchor.constant = 60 + translation.y * 0.3 + popupView.frame.height

        if sender.state == .ended {

            if abs(velocity.y) > 700 {
                UIView.animate(withDuration: 0.2) { [weak self] in
                    guard let strongSelf = self else { return }
                    if velocity.y < 0 {
                        strongSelf.bottomPopUpAnchor.constant = 0

                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first {
                            window.layoutIfNeeded()
                        }
                        
                    } else {
                        strongSelf.bottomPopUpAnchor.constant = strongSelf.popupView.frame.height + 60
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first {
                            window.layoutIfNeeded()
                        }

                        strongSelf.timer = Timer.scheduledTimer(timeInterval: 4, target: strongSelf, selector: #selector(strongSelf.fireTimer), userInfo: strongSelf.popupView, repeats: false)
                    }
                }
            } else {
                UIView.animate(withDuration: 0.3) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.bottomPopUpAnchor.constant = strongSelf.popupView.frame.height + 60
                    
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        window.layoutIfNeeded()
                    }

                    strongSelf.timer = Timer.scheduledTimer(timeInterval: 4, target: strongSelf, selector: #selector(strongSelf.fireTimer), userInfo: strongSelf.popupView, repeats: false)
                }
            }
        }
    }
}

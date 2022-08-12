//
//  METopPopupView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/8/22.
//

import UIKit

class METopPopupView: UIView {
    
    private var title: String
    private var image: String
    private var userDidPanPopup: Bool = false
    
    
    private var timer: Timer?

    init(title: String, image: String) {
        self.title = title
        self.image = image
        super.init(frame: .zero)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.borderColor = primaryColor.cgColor
        layer.borderWidth = 1
        backgroundColor = softPrimaryColor
        layer.cornerRadius = 10
        clipsToBounds = false
    }
    
    func showTopPopup(inView view: UIView) {
        configurePopup(in: view)
        isUserInteractionEnabled = true


    }
    
    func handleDismissPopup(view: PopupView) {
        if userDidPanPopup {
            
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 1, options: .curveEaseOut) {
                self.frame = CGRect(x: 10, y: -55, width: UIScreen.main.bounds.width - 20, height: 50)
                view.frame = self.frame
            }
        }
    }
    
    
    func configurePopup(in view: UIView) {
        let popupView = PopupView(title: title, image: image)
        
        timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.fireTimer), userInfo: popupView, repeats: true)
        
        let context = popupView
        if let window = UIApplication.shared.keyWindow {
            //window.addSubview(blackBackgroundView)
            window.addSubview(self)
            window.addSubview(popupView)
        }
        
        frame = CGRect(x: 10, y: -55, width: UIScreen.main.bounds.width - 20, height: 50)
        popupView.frame = frame
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.alpha = 1
            self.frame = CGRect(x: 10, y: 55, width: UIScreen.main.bounds.width - 20, height: 50)
            popupView.frame = self.frame
            
        })
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        popupView.addGestureRecognizer(pan)
    }
    
    @objc func fireTimer() {
        guard let timer = timer, let popView = timer.userInfo as? PopupView else {
            return
        }
        timer.invalidate()
        handleDismissPopup(view: popView)
    }
    
    @objc func handlePan(sender: UIPanGestureRecognizer) {
        print("pan called")
        let translation = sender.translation(in: self)
        print(translation.y)
        /*
        collectionView.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.height - menuHeight + translation.y * 0.3)
        
        if sender.state == .ended {
            if translation.y > 0 && translation.y > menuHeight * 0.3 {
                UIView.animate(withDuration: 0.3) {
                    self.handleDismiss(selectedOption: "")
                }
            } else {
                UIView.animate(withDuration: 0.5) {
                    self.collectionView.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.height - self.menuHeight)
                    self.collectionView.frame.size.height = self.menuHeight
                }
            }
        } else {
            collectionView.frame.size.height = menuHeight - translation.y * 0.3
        }
         */
    }
}

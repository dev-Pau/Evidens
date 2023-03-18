//
//  MEPrimaryLockView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/3/23.
//

import UIKit

class MEPrimaryLockView: UIView {
    
    private let lockImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: "lock.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.systemGray2)
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubview(lockImageView)
        NSLayoutConstraint.activate([
            lockImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            lockImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            lockImageView.heightAnchor.constraint(equalToConstant: 120),
            lockImageView.widthAnchor.constraint(equalToConstant: 100)
        ])
        /*
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
         */
        
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(blurView, at: 0)
        blurView.frame = bounds
    }
}

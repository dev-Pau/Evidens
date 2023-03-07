//
//  ProfileHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/10/21.
//

import UIKit

class MEStretchyHeader: UICollectionReusableView {
    
    //MARK: - Properties
    
    private let bannerImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        //iv.isUserInteractionEnabled = true
        iv.backgroundColor = primaryColor.withAlphaComponent(0.5)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
  
    //MARK:  - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    func configure() {
        addSubview(bannerImageView)
        NSLayoutConstraint.activate([
            bannerImageView.topAnchor.constraint(equalTo: topAnchor),
            bannerImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bannerImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bannerImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    var animator: UIViewPropertyAnimator!
    
    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    func configureBlurView() {
        addSubview(visualEffectView)
        visualEffectView.fillSuperview()
        
        animator = UIViewPropertyAnimator(duration: 1.0, curve: .linear, animations: {
            self.visualEffectView.effect = nil
        })
        
        animator.isReversed = true
        animator.fractionComplete = 0
        
        //animator.startAnimation()
    }
    
    func setImageWithStringUrl(imageUrl: String) {
        bannerImageView.sd_setImage(with: URL(string: imageUrl))
    }
    
    
}

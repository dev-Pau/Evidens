//
//  TabBarIconCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/3/24.
//

import UIKit

class TabBarIconCell: UICollectionViewCell {
    
    private var isAnimating: Bool = false
    
    private lazy var badgeButton = UIButton(type: .system)
    
    override var isSelected: Bool {
        didSet {
            guard let tabIcon = tabIcon else { return }
            
            
            switch tabIcon {
            case .cases, .network:
                let image = isSelected ? tabIcon.selectedImage.scalePreservingAspectRatio(targetSize: CGSize(width: 32, height: 32)) : tabIcon.padImage.scalePreservingAspectRatio(targetSize: CGSize(width: 32, height: 32))
                animateBounce(scale: isSelected ? 0.8 : 1.0, image: image)
            case .notifications, .search, .bookmark, .drafts:
                let image = isSelected ? tabIcon.selectedImage.scalePreservingAspectRatio(targetSize: CGSize(width: 28, height: 28)) : tabIcon.padImage.scalePreservingAspectRatio(targetSize: CGSize(width: 28, height: 28))
                animateBounce(scale: isSelected ? 0.8 : 1.0, image: image)
            case .icon, .resources:
                break
            case .profile:
                animateBounce(scale: isSelected ? 0.8 : 1.0)
                button.layer.borderColor = isSelected ? K.Colors.primaryColor.cgColor : K.Colors.separatorColor.cgColor
            }
        }
    }
    
    private var button: UIImageView!
    
    var tabIcon: TabIcon? {
        didSet {
            configureIcon()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        button = UIImageView()
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor, constant: 25),
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -25),
            button.heightAnchor.constraint(equalToConstant: 35),
            button.widthAnchor.constraint(equalToConstant: 35)
        ])

        button.isUserInteractionEnabled = false
    
    }
    
    private func configureIcon() {
        guard let tabIcon else { return }
        
        switch tabIcon {
        case .icon:
            button.contentMode = .center
            button.image = tabIcon.padImage
        case .cases, .network:
            button.contentMode = .center
            button.image = tabIcon.padImage.scalePreservingAspectRatio(targetSize: CGSize(width: 32, height: 32))
        case .notifications, .search, .bookmark, .drafts, .resources:
            button.contentMode = .center
            button.image = tabIcon.padImage.scalePreservingAspectRatio(targetSize: CGSize(width: 28, height: 28))
        case .profile:
            button.contentMode = .scaleAspectFit
            configureProfile()
        }
        
        if tabIcon == .notifications {
            NotificationCenter.default.addObserver(self, selector: #selector(refreshUnreadNotifications(_:)), name: NSNotification.Name(AppPublishers.Names.refreshUnreadNotifications), object: nil)
            badgeButton.isHidden = true
            var configuration = UIButton.Configuration.filled()
            configuration.baseBackgroundColor = K.Colors.primaryColor
            configuration.baseForegroundColor = .white
            configuration.buttonSize = .mini
            configuration.cornerStyle = .capsule
          
            badgeButton.configuration = configuration
            badgeButton.translatesAutoresizingMaskIntoConstraints = false
            badgeButton.isUserInteractionEnabled = false
            
            addSubview(badgeButton)
            
            NSLayoutConstraint.activate([
                badgeButton.centerYAnchor.constraint(equalTo: button.topAnchor, constant: 5),
                badgeButton.centerXAnchor.constraint(equalTo: button.trailingAnchor, constant: -5),
                badgeButton.heightAnchor.constraint(equalToConstant: 10),
                badgeButton.widthAnchor.constraint(equalToConstant: 10)
            ])
        }
    }
    
    func configureProfile() {
        addImage(forUrl: UserDefaults.getImage(), size: 35)
        button.layer.borderColor = K.Colors.separatorColor.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 35 / 2
    }
    
    func animateBounce(scale: CGFloat, image: UIImage? = nil) {
        guard !isAnimating else { return }
        isAnimating = true
        
        UIView.animate(withDuration: 0.1) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.button.transform = CGAffineTransform(scaleX: scale, y: scale)
        } completion: { [weak self] _ in
            UIView.animate(withDuration: 0.1) { [weak self] in
                guard let strongSelf = self else { return }
                
                if let image {
                    strongSelf.button.image = image
                }
                
                strongSelf.button.transform = CGAffineTransform.identity
            } completion: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.isAnimating = false
            }
        }
    }
    
    func addImage(forUrl string: String?, size: CGFloat) {
        button.image = nil
        button.subviews.forEach { $0.removeFromSuperview() }
        
        if let string, string != String() {
            button.backgroundColor = .quaternarySystemFill
            button.image = nil
            button.sd_setImage(with: URL(string: string))
        } else {
            if let username = UserDefaults.getUsername(), let first = username.first {
                button.backgroundColor = K.Colors.primaryColor
                
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.textColor = .white
                
                let charSize = size * 0.6
                
                let systemFont = UIFont.systemFont(ofSize: charSize, weight: .bold)
                
                if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
                    label.font = UIFont(descriptor: descriptor, size: charSize)
                } else {
                    label.font = systemFont
                }
                
                label.text = first.uppercased()
                
                addSubviews(label)
                
                NSLayoutConstraint.activate([
                    label.centerXAnchor.constraint(equalTo: centerXAnchor),
                    label.centerYAnchor.constraint(equalTo: centerYAnchor)
                ])
            } else {
                button.backgroundColor = .quaternarySystemFill
            }
        }
    }
    
    
    @objc func refreshUnreadNotifications(_ notification: NSNotification) {
        if let notifications = notification.userInfo?["notifications"] as? Int {
            
            if notifications > 0 {
                badgeButton.isHidden = false
            } else {
                badgeButton.isHidden = true
            }
        }
    }
}

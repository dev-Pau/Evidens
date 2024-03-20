//
//  TabBarIconCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/3/24.
//

import UIKit

class TabBarIconCell: UICollectionViewCell {
    
    private var isAnimating: Bool = false
    
    override var isSelected: Bool {
        didSet {
            guard let tabIcon = tabIcon else { return }
            animateBounce(scale: isSelected ? 0.8 : 1.0)
            switch tabIcon {
                
            case .cases, .network, .notifications, .search, .bookmark, .drafts:
                button.image = isSelected ? tabIcon.selectedImage : tabIcon.padImage
            case .icon, .resources:
                break
            case .profile:
                button.layer.borderColor = isSelected ? primaryColor.cgColor : separatorColor.cgColor
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
        button.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor, constant: 30),
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30),
            button.heightAnchor.constraint(equalToConstant: 28),
            button.widthAnchor.constraint(equalToConstant: 28)
        ])

        button.isUserInteractionEnabled = false

    }
    
    private func configureIcon() {
        guard let tabIcon else { return }
        if tabIcon == .profile {
            addImage(forUrl: UserDefaults.getImage(), size: 28)
            button.layer.borderColor = separatorColor.cgColor
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 28 / 2
        } else {
            button.image = tabIcon.padImage
        }
    }
    
    private func animateBounce(scale: CGFloat) {
        guard !isAnimating else { return }
        isAnimating = true
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: [.curveEaseInOut]) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.button.transform = CGAffineTransform(scaleX: scale, y: scale)
            strongSelf.layoutIfNeeded()
        } completion: { [weak self] _ in
            guard let _ = self else { return }
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: [.curveEaseOut]) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.button.transform = CGAffineTransform.identity
                strongSelf.layoutIfNeeded()
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
                button.backgroundColor = primaryColor
                
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

}

//
//  PrimaryProfileImageView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/6/22.
//

import UIKit
import SDWebImage

class ProfileImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        contentMode = .scaleAspectFill
        clipsToBounds = true
        isUserInteractionEnabled = true
    }
    
    func addImage(forUser user: User, size: CGFloat) {
        image = nil
        subviews.forEach { $0.removeFromSuperview() }
        
        let phase = user.phase
        
        switch phase {
            
        case .verified:
            if let userImage = user.profileUrl, userImage != String() {
                backgroundColor = .quaternarySystemFill
                self.sd_setImage(with: URL(string: userImage))
            } else {
                if let username = user.username, let first = username.first {
                    backgroundColor = K.Colors.primaryColor
                    
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
                    backgroundColor = .quaternarySystemFill
                }
            }
        default:
            hide()
        }
    }
    
    func addImage(forUrl string: String?, size: CGFloat) {
        image = nil
        subviews.forEach { $0.removeFromSuperview() }
        
        if let string, string != String() {
            backgroundColor = .quaternarySystemFill
            image = nil
            self.sd_setImage(with: URL(string: string))
        } else {
            if let username = UserDefaults.getUsername(), let first = username.first {
                backgroundColor = K.Colors.primaryColor
                
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
                backgroundColor = .quaternarySystemFill
            }
        }
    }
    
    func addImage(forUrl string: String?, forUsername username: String?, size: CGFloat) {
        image = nil
        subviews.forEach { $0.removeFromSuperview() }
        
        if let string, string != String() {
            backgroundColor = .quaternarySystemFill
            self.sd_setImage(with: URL(string: string))
        } else {
            if let username, let first = username.first {
                backgroundColor = K.Colors.primaryColor
                
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
                backgroundColor = .quaternarySystemFill
            }
        }
    }
    
    func anonymize() {
        backgroundColor = .quaternarySystemFill
        image = nil
        subviews.forEach { $0.removeFromSuperview() }
        image = UIImage(named: AppStrings.Assets.privacyProfile)
    }
    
    func hide() {
        backgroundColor = .quaternarySystemFill
        image = nil
        subviews.forEach { $0.removeFromSuperview() }
        image = UIImage(named: AppStrings.Assets.profile)
    }
}

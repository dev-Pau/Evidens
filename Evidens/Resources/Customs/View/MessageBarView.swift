//
//  MessageBarView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/6/23.
//

import UIKit

class MessageBarView: UIView {

    private lazy var paperplaneButton: UIButton = {
        let button = UIButton()
        button.configuration = .plain()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.image = UIImage(named: AppStrings.Assets.paperplane)?.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal).withTintColor(.label)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private let unreadMessagesButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintAdjustmentMode = .normal
        button.configuration = .filled()
        button.isUserInteractionEnabled = false
        button.isHidden = true
        button.configuration?.baseBackgroundColor = primaryColor
        button.configuration?.baseForegroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4)
        button.configuration?.buttonSize = .mini
        button.configuration?.cornerStyle = .capsule
        button.isUserInteractionEnabled = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubviews(paperplaneButton, unreadMessagesButton)
        NSLayoutConstraint.activate([
            paperplaneButton.topAnchor.constraint(equalTo: topAnchor),
            paperplaneButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            paperplaneButton.heightAnchor.constraint(equalToConstant: 26),
            paperplaneButton.widthAnchor.constraint(equalToConstant: 26),
            paperplaneButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            paperplaneButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            unreadMessagesButton.centerYAnchor.constraint(equalTo: paperplaneButton.topAnchor, constant: 4),
            unreadMessagesButton.centerXAnchor.constraint(equalTo: paperplaneButton.trailingAnchor, constant: -2),
            unreadMessagesButton.heightAnchor.constraint(equalToConstant: 18),
            unreadMessagesButton.widthAnchor.constraint(equalToConstant: 18),
        ])
    }
    
    func setUnreadMessages(_ unread: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.unreadMessagesButton.isHidden = unread == 0 ? true : false
            
            if unread < 9 {
                var container = AttributeContainer()
                container.font = UIFont.addFont(size: 11, scaleStyle: .body, weight: .medium, scales: false)
                strongSelf.unreadMessagesButton.configuration?.attributedTitle = AttributedString(String(unread), attributes: container)
            }
        }
    }
}


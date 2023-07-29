//
//  MessageBarView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/6/23.
//

import UIKit

class MessageBarView: UIView {
    
    let paperplaneImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: AppStrings.Assets.paperplane)!.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let unreadMessagesButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.isUserInteractionEnabled = false
        button.configuration?.baseBackgroundColor = .systemRed
        button.configuration?.baseForegroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4)
        button.configuration?.buttonSize = .mini
        button.configuration?.cornerStyle = .capsule
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
        addSubviews(paperplaneImageView, unreadMessagesButton)
        NSLayoutConstraint.activate([
            paperplaneImageView.topAnchor.constraint(equalTo: topAnchor),
            paperplaneImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            paperplaneImageView.heightAnchor.constraint(equalToConstant: 25),
            paperplaneImageView.widthAnchor.constraint(equalToConstant: 25),
            paperplaneImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            paperplaneImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            unreadMessagesButton.centerYAnchor.constraint(equalTo: paperplaneImageView.topAnchor, constant: 2),
            unreadMessagesButton.centerXAnchor.constraint(equalTo: paperplaneImageView.trailingAnchor, constant: -2),
        ])
    }
    
    func setUnreadMessages(_ unread: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.unreadMessagesButton.isHidden = unread == 0 ? true : false
            var container = AttributeContainer()
            container.font = .systemFont(ofSize: 11, weight: .medium)
            strongSelf.unreadMessagesButton.configuration?.attributedTitle = AttributedString(String(unread), attributes: container)
        }
    }
}


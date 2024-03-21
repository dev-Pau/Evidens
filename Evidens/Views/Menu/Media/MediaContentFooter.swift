//
//  MediaContentFooter.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/3/24.
//

import UIKit

class MediaContentFooter: UICollectionReusableView {
    
    private let padding: CGFloat = 15

    private let contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = K.Colors.primaryGray
        label.font = UIFont.addFont(size: 12, scaleStyle: .title2, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = K.Colors.separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        addSubview(contentLabel)

        NSLayoutConstraint.activate([
            contentLabel.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            contentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            contentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            contentLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding / 2),
        ])
        
        
    }
    
    func set(imageKind: ImageKind) {
        switch imageKind {
            
        case .profile:
            contentLabel.text = AppStrings.Menu.mediaProfile
        case .banner:
            contentLabel.text = AppStrings.Menu.bannerProfile
        }
    }
}

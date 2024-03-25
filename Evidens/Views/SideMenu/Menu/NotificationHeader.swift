//
//  NotificationGroupHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/6/23.
//

import UIKit

class NotificationHeader: UICollectionReusableView {
    
    private let title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.font = UIFont.addFont(size: 18.0, scaleStyle: .title3, weight: .heavy)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubviews(title)
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: topAnchor, constant: K.Paddings.Settings.verticalPadding),
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: K.Paddings.Settings.horizontalPadding),
            title.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -K.Paddings.Settings.horizontalPadding),
            title.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -K.Paddings.Settings.verticalPadding)
        ])
    }
    
    func set(title: String) {
        self.title.text = title
    }
}


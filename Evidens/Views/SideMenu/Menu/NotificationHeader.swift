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

        let customFontSize: CGFloat = 18.0
        let fontMetrics = UIFontMetrics(forTextStyle: .headline)
        let scaledFontSize = fontMetrics.scaledValue(for: customFontSize)
        
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .headline)
        let heavyFontDescriptor = fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.traits: [
                UIFontDescriptor.TraitKey.weight: UIFont.Weight.heavy.rawValue
            ]
        ])
        
        label.font = UIFont(descriptor: heavyFontDescriptor, size: scaledFontSize)

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
            title.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            title.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            title.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    func set(title: String) {
        self.title.text = title
    }
}


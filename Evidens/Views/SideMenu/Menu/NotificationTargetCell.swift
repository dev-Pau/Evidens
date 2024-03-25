//
//  NotificationTargetCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/6/23.
//

import UIKit

class NotificationTargetCell: UICollectionViewCell {

    private let title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 15.0, scaleStyle: .title3, weight: .semibold)
       
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let onOffLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 15.0, scaleStyle: .title3, weight: .medium)
        label.textColor = K.Colors.primaryGray
        label.numberOfLines = 0
        label.textAlignment = .right
        return label
    }()
    
    private let chevronImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .center
        iv.clipsToBounds = true
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
        addSubviews(title, onOffLabel, chevronImage)
        NSLayoutConstraint.activate([
            
            chevronImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -K.Paddings.Settings.horizontalPadding),
            chevronImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronImage.widthAnchor.constraint(equalToConstant: 20),
            chevronImage.heightAnchor.constraint(equalToConstant: 20),
            
            onOffLabel.trailingAnchor.constraint(equalTo: chevronImage.leadingAnchor, constant: -K.Paddings.Settings.horizontalPadding),
            onOffLabel.centerYAnchor.constraint(equalTo: chevronImage.centerYAnchor),
            onOffLabel.widthAnchor.constraint(equalToConstant: 100),
            
            title.topAnchor.constraint(equalTo: topAnchor, constant: K.Paddings.Settings.verticalPadding),
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: K.Paddings.Settings.horizontalPadding),
            title.trailingAnchor.constraint(equalTo: onOffLabel.leadingAnchor, constant: -10),
            title.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -K.Paddings.Settings.verticalPadding)
            
        ])
        
        chevronImage.image = UIImage(systemName: AppStrings.Icons.rightChevron, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(K.Colors.separatorColor)
    }
    
    func set(onOff: Bool) {
        onOffLabel.text = onOff ? AppStrings.Miscellaneous.on : AppStrings.Miscellaneous.off
    }
    
    func set(title: String) {
        self.title.text = title
    }
    
    func hide() {
        onOffLabel.isHidden = true
    }
}

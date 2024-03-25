//
//  NotificationToggleCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/6/23.
//

import UIKit

protocol NotificationToggleCellDelegate: AnyObject {
    func didToggle(_ cell: UICollectionViewCell, _ value: Bool)
}

class NotificationToggleCell: UICollectionViewCell {
    
    weak var delegate: NotificationToggleCellDelegate?
    
    private let title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 15.0, scaleStyle: .title3, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let uiSwitch: UISwitch = {
        let uiSwitch = UISwitch()
        uiSwitch.translatesAutoresizingMaskIntoConstraints = false
        return uiSwitch
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubviews(title, uiSwitch)
        NSLayoutConstraint.activate([
            uiSwitch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -K.Paddings.Settings.horizontalPadding),
            uiSwitch.centerYAnchor.constraint(equalTo: centerYAnchor),

            title.topAnchor.constraint(equalTo: topAnchor, constant: K.Paddings.Settings.verticalPadding),
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: K.Paddings.Settings.horizontalPadding),
            title.trailingAnchor.constraint(equalTo: uiSwitch.leadingAnchor, constant: -K.Paddings.Settings.horizontalPadding),
            title.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -K.Paddings.Settings.verticalPadding)
        ])
        
        uiSwitch.addTarget(self, action: #selector(didToggleSwitch), for: .valueChanged)
    }
    
    func set(title: String) {
        self.title.text = title
    }
    
    func set(isOn: Bool) {
        uiSwitch.isOn = isOn
    }
    
    func switchToggle() {
        uiSwitch.isOn = !uiSwitch.isOn
    }
    
    @objc func didToggleSwitch() {
        let isOn = uiSwitch.isOn
        delegate?.didToggle(self, isOn)
    }
}


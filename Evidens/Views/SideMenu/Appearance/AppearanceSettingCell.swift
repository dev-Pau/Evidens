//
//  AppearanceSettingCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/3/23.
//

import UIKit

protocol AppearanceSettingsCellDelegate: AnyObject {
    func didTapSwitch(_ sw: UISwitch, appearance: Appearance)
}

class AppearanceSettingCell: UICollectionViewCell {
    weak var delegate: AppearanceSettingsCellDelegate?
    
    var appearance: Appearance? {
        didSet {
            configureWithAppearance()
        }
    }
    
    private lazy var appearanceSwitch: UISwitch = {
        let sw = UISwitch()
        sw.translatesAutoresizingMaskIntoConstraints = false
        sw.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        return sw
    }()
    
    private let appearanceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
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
        backgroundColor = .systemBackground
        addSubviews(appearanceSwitch, appearanceLabel)
        
        NSLayoutConstraint.activate([
            appearanceSwitch.centerYAnchor.constraint(equalTo: centerYAnchor),
            appearanceSwitch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            appearanceLabel.centerYAnchor.constraint(equalTo: appearanceSwitch.centerYAnchor),
            appearanceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            appearanceLabel.trailingAnchor.constraint(equalTo: appearanceSwitch.trailingAnchor, constant: -10)
        ])
    }
    
    func openSwitch() {
        appearanceSwitch.setOn(true, animated: true)
    }
    
    func closeSwitch() {
        appearanceSwitch.setOn(false, animated: true)
    }
    
    @objc func switchChanged() {
        guard let appearance = appearance else { return }
        delegate?.didTapSwitch(appearanceSwitch, appearance: appearance)
    }
    
    
    func configureWithAppearance() {
        guard let defaultAppearance = UserDefaults.standard.value(forKey: "themeStateEnum") as? Int, let appearance = appearance else { return }
        let defaultsTheme = Appearance(rawValue: defaultAppearance)

        if defaultsTheme == appearance {
            appearanceSwitch.isOn = true
        } else if defaultsTheme == .system && UIScreen.main.traitCollection.userInterfaceStyle == .dark {
            // Default settings && default is dark mode
            appearanceSwitch.isOn = true
        }

        appearanceLabel.text = appearance.title
    }
}

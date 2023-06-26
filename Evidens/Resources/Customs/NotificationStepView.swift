//
//  NotificationStepView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/6/23.
//

import UIKit

class NotificationStepView: UIView {
    
    private let notificationFlow: NotificationFlow
    
    private let number: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private let content: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .label
        button.configuration?.baseForegroundColor = .systemBackground
        button.configuration?.cornerStyle = .capsule
        return button
    }()
    
    init(notificationFlow: NotificationFlow) {
        self.notificationFlow = notificationFlow
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        
        var view: UIView!

        switch notificationFlow {
        case .tap:
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.configuration = .filled()
            button.configuration?.image = UIImage(systemName: AppStrings.Icons.badgeBell, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
            button.configuration?.baseBackgroundColor = .systemRed
            button.configuration?.cornerStyle = .medium
            button.configuration?.buttonSize = .mini
            view = button
        case .turn:
            let uiSwitch = UISwitch()
            uiSwitch.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            
            uiSwitch.translatesAutoresizingMaskIntoConstraints = false
            uiSwitch.isOn = true
            uiSwitch.isUserInteractionEnabled = false
            view = uiSwitch
        }
        
        view.translatesAutoresizingMaskIntoConstraints = false

        addSubviews(number, view, content)
        NSLayoutConstraint.activate([
            number.centerYAnchor.constraint(equalTo: centerYAnchor),
            number.leadingAnchor.constraint(equalTo: leadingAnchor),
            number.widthAnchor.constraint(equalToConstant: 15),
            
            view.centerYAnchor.constraint(equalTo: centerYAnchor),
            view.leadingAnchor.constraint(equalTo: number.trailingAnchor, constant: notificationFlow == .tap ? 10 : 2),
            view.heightAnchor.constraint(equalToConstant: 30),
            view.widthAnchor.constraint(equalToConstant: 30),
            
            content.centerYAnchor.constraint(equalTo: centerYAnchor),
            content.leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: notificationFlow == .tap ? 10 : 17),
            content.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
        number.text = "\(notificationFlow.rawValue)."
        content.text = notificationFlow.title
    }
}

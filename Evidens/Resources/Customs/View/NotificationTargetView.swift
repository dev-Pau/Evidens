//
//  NotificationTargetView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/6/23.
//

import UIKit

class NotificationTargetView: UIView {
    
    private let title: String
    private(set) var isOn: Bool {
        didSet {
            configureImage()
        }
    }
    
    private let targetLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .medium)
       
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let targetImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(systemName: AppStrings.Icons.circle)?.withRenderingMode(.alwaysOriginal).withTintColor(separatorColor)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    init(title: String, isOn: Bool) {
        self.title = title
        self.isOn = isOn
        super.init(frame: .zero)
        configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true
        addSubviews(targetLabel, targetImageView)
        NSLayoutConstraint.activate([
            targetLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            targetLabel.trailingAnchor.constraint(equalTo: targetImageView.leadingAnchor, constant: -10),
            targetLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            targetImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            targetImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            targetImageView.heightAnchor.constraint(equalToConstant: 25),
            targetImageView.widthAnchor.constraint(equalToConstant: 25)
        ])
        
        targetLabel.text = title
        configureImage()
        
        
    }
    
    private func configureImage() {
        targetImageView.image = UIImage(systemName: isOn ? AppStrings.Icons.checkmarkCircleFill : AppStrings.Icons.circle)?.withRenderingMode(.alwaysOriginal).withTintColor((isOn ? primaryColor : separatorColor))
    }
    
    func set(isOn: Bool) {
        self.isOn = isOn
        configureImage()
    }
}

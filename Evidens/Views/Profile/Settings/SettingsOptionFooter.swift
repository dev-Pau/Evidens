//
//  SettingOptionFooter.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/9/22.
//

import UIKit

protocol SettingsOptionFooterDelegate: AnyObject {
    func didTapLogout()
}

class SettingsOptionFooter: UITableViewHeaderFooterView {
    
    weak var delegate: SettingsOptionFooterDelegate?
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = lightGrayColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var logoutLabel: UILabel = {
        let label = UILabel()
        label.text = "Log out"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = primaryColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLogout)))
        return label
    }()
    
    private let versionLabel: UILabel = {
        let label = UILabel()
        label.text = "Version: 0.1.0"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = grayColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
 
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        contentView.addSubviews(separatorView, logoutLabel, versionLabel)
        
        NSLayoutConstraint.activate([
            
            separatorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            logoutLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10),
            logoutLabel.leadingAnchor.constraint(equalTo: separatorView.leadingAnchor, constant: 10),
            logoutLabel.trailingAnchor.constraint(equalTo: separatorView.trailingAnchor, constant: -10),
            
            versionLabel.topAnchor.constraint(equalTo: logoutLabel.bottomAnchor, constant: 10),
            versionLabel.leadingAnchor.constraint(equalTo: logoutLabel.leadingAnchor),
            versionLabel.trailingAnchor.constraint(equalTo: versionLabel.trailingAnchor)

        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleLogout() {
        delegate?.didTapLogout()
    }
    
    
}

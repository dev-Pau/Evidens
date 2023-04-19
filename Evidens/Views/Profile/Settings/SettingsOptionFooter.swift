//
//  SettingOptionFooter.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/9/22.
//

import UIKit

protocol SettingsOptionFooterDelegate: AnyObject {
    func didTapLogout()
}

class SettingsOptionFooter: UITableViewHeaderFooterView {
    
    weak var delegate: SettingsOptionFooterDelegate?
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var logoutLabel: UILabel = {
        let label = UILabel()
        label.text = "Log out"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLogout)))
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        backgroundColor = .systemBackground
        contentView.addSubviews(separatorView, logoutLabel)
        
        NSLayoutConstraint.activate([
            
            separatorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            
            logoutLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10),
            logoutLabel.leadingAnchor.constraint(equalTo: separatorView.leadingAnchor, constant: 10),
            logoutLabel.trailingAnchor.constraint(equalTo: separatorView.trailingAnchor, constant: -10),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleLogout() {
        delegate?.didTapLogout()
    }
    
    
}

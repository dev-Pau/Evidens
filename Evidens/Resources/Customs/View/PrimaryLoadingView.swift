//
//  MEProgressHUD.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/2/23.
//

import UIKit

class PrimaryLoadingView: UIView {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.text = AppStrings.Miscellaneous.capsLoading
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.tintColor = .secondaryLabel
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        addSubviews(activityIndicator, titleLabel)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: topAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 5)
        ])
    
        activityIndicator.startAnimating()
    }

    func stop() {
        activityIndicator.stopAnimating()
    }
    
    func start() {
        activityIndicator.startAnimating()
    }
}

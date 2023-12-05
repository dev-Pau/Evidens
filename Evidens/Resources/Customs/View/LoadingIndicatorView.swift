//
//  MEProgressHUD.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/2/23.
//

import UIKit

class LoadingIndicatorView: UIScrollView {

    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.tintColor = .secondaryLabel
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.clipsToBounds = true
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
        bounces = true
        alwaysBounceVertical = true
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        addSubviews(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor)
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

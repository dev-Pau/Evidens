//
//  PrimaryProgressIndicator.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/8/23.
//

import UIKit

class ProgressIndicatorView: UIView {
    
    private let progressIndicator = UIActivityIndicatorView(style: .large)
    
    private let square: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.4)
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .label.withAlphaComponent(0)
        progressIndicator.color = .white
        progressIndicator.alpha = 0
        progressIndicator.translatesAutoresizingMaskIntoConstraints = false
        square.layer.cornerRadius = 10
        addSubview(square)
        addSubview(progressIndicator)
        
        square.frame = CGRect(origin: CGPoint(x: frame.width / 2 - 125, y: frame.height / 2 - 125), size: CGSize(width: 250, height: 250))
        square.backgroundColor = .black.withAlphaComponent(0)
        NSLayoutConstraint.activate([
            progressIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    func show() {
        progressIndicator.startAnimating()

        UIView.animate(withDuration: 0.4) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.backgroundColor = .label.withAlphaComponent(0.4)
            strongSelf.square.backgroundColor = .black.withAlphaComponent(0.5)
            strongSelf.progressIndicator.alpha = 1
            strongSelf.square.frame = CGRect(origin: CGPoint(x: strongSelf.frame.width / 2 - 155/2, y: strongSelf.frame.height / 2 - 155/2), size: CGSize(width: 155, height: 155))
        }
    }
    
    func dismiss() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            
            UIView.animate(withDuration: 0.4) {
                strongSelf.backgroundColor = .label.withAlphaComponent(0.0)
                strongSelf.square.backgroundColor = .black.withAlphaComponent(0.0)
                strongSelf.progressIndicator.alpha = 0
                strongSelf.square.frame = CGRect(origin: CGPoint(x: strongSelf.frame.width / 2 - 80/2, y: strongSelf.frame.height / 2 - 80/2), size: CGSize(width: 80, height: 80))
            } completion: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.removeFromSuperview()
            }
        }
    }
}

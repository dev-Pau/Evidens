//
//  PostMenuHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 11/6/22.
//

import UIKit

protocol PostMenuHeaderDelegate: AnyObject {
    func didTapCancelMenuButton()
}

class PostMenuHeader: UICollectionReusableView {
    
    weak var delegate: PostMenuHeaderDelegate?
    
    private let padding: CGFloat = 10
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create"
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = primaryColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubview(titleLabel)
        addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            cancelButton.heightAnchor.constraint(equalToConstant: 40),
            cancelButton.widthAnchor.constraint(equalToConstant: 40),
            
            titleLabel.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: cancelButton.leadingAnchor, constant: -padding),
            titleLabel.heightAnchor.constraint(equalToConstant: 40) 
        ])
    }
    
    @objc func handleDismiss() {
        delegate?.didTapCancelMenuButton()
    }
}

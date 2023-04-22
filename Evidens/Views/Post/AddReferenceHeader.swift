//
//  AddReferenceHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/4/23.
//

import UIKit

class AddReferenceHeader: UICollectionReusableView {
    
    var reference: Reference? {
        didSet {
            configureWithReference()
        }
    }
    
    private let referenceImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let referenceLabel: UILabel = {
        let label = UILabel()
        label.textColor = primaryColor
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = separatorColor
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
        addSubviews(referenceImageView, referenceLabel, separatorView)
        NSLayoutConstraint.activate([
            referenceImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            referenceImageView.heightAnchor.constraint(equalToConstant: 20),
            referenceImageView.widthAnchor.constraint(equalToConstant: 20),
            referenceImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            referenceLabel.centerYAnchor.constraint(equalTo: referenceImageView.centerYAnchor),
            referenceLabel.leadingAnchor.constraint(equalTo: referenceImageView.trailingAnchor, constant: 10),
            referenceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func configureWithReference() {
        guard let reference = reference else { return }
        referenceLabel.text = reference.option == .link ? "Link Reference" : "Author Citation"
        referenceImageView.image = reference.option.image
    }
}

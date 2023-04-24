//
//  MEReferenceView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/4/23.
//

import UIKit

protocol MEReferenceViewDelegate: AnyObject {
    func didTapShowReference()
}

class MEReferenceView: UIView {
    weak var delegate: MEReferenceViewDelegate?
    
    private lazy var referenceImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleReferenceTap)))
        return iv
    }()
    
    private lazy var referenceLabel: UILabel = {
        let label = UILabel()
        label.textColor = primaryColor
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleReferenceTap)))
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(referenceImageView, referenceLabel)
        NSLayoutConstraint.activate([
            referenceImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 3),
            referenceImageView.heightAnchor.constraint(equalToConstant: 20),
            referenceImageView.widthAnchor.constraint(equalToConstant: 20),
            referenceImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            referenceLabel.centerYAnchor.constraint(equalTo: referenceImageView.centerYAnchor),
            referenceLabel.leadingAnchor.constraint(equalTo: referenceImageView.trailingAnchor, constant: 5),
            referenceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleReferenceTap() {
        delegate?.didTapShowReference()
    }
    
    func configureWithReference(_ reference: Reference, referenceText: String) {
        referenceImageView.image = reference.option.image
        referenceLabel.text = referenceText
    }
}

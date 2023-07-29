//
//  ReferenceHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/4/23.
//

import UIKit

protocol ReferenceHeaderDelegate: AnyObject {
    func didTapEditReference(_ reference: Reference)
}

class ReferenceHeader: UICollectionReusableView {
    weak var delegate: ReferenceHeaderDelegate?
    var reference: Reference? {
        didSet {
            configureWithReference()
        }
    }
    
    private lazy var referenceImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleEditReference)))
        return iv
    }()
    
    private lazy var referenceLabel: UILabel = {
        let label = UILabel()
        label.textColor = primaryColor
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleEditReference)))
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
        addSubviews(referenceImageView, referenceLabel)
        NSLayoutConstraint.activate([
            referenceImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            referenceImageView.heightAnchor.constraint(equalToConstant: 20),
            referenceImageView.widthAnchor.constraint(equalToConstant: 20),
            referenceImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            referenceLabel.centerYAnchor.constraint(equalTo: referenceImageView.centerYAnchor),
            referenceLabel.leadingAnchor.constraint(equalTo: referenceImageView.trailingAnchor, constant: 5),
            referenceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
        ])
    }
    
    private func configureWithReference() {
        guard let reference = reference else { return }
        referenceLabel.text = reference.option == .link ? AppStrings.Reference.linkTitle : AppStrings.Reference.citationTitle
        referenceImageView.image = reference.option.image
    }
    
    @objc func handleEditReference() {
        guard let reference = reference else { return }
        delegate?.didTapEditReference(reference)
    }
}

//
//  CasePrivacyCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/5/23.
//

import UIKit

class CasePrivacyCell: UICollectionViewCell {
    
    var viewModel: ShareCaseViewModel? {
        didSet {
            configureWithPrivacy()
        }
    }
    
    private let privacyTypeImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var privacyLabel: UILabel = {
        let label = UILabel()
        label.textColor = primaryGray
        label.isUserInteractionEnabled = true
        label.numberOfLines = 2
        label.font = UIFont.addFont(size: 15, scaleStyle: .title1, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
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
        addSubviews(privacyTypeImage, privacyLabel, separatorView)
        NSLayoutConstraint.activate([
            privacyTypeImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            privacyTypeImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            privacyTypeImage.heightAnchor.constraint(equalToConstant: 23),
            privacyTypeImage.widthAnchor.constraint(equalToConstant: 23),
            
            privacyLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            privacyLabel.leadingAnchor.constraint(equalTo: privacyTypeImage.trailingAnchor, constant: 10),
            privacyLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            privacyLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor)
            
        ])
    }
    
    private func configureWithPrivacy() {
        guard let viewModel = viewModel else { return }
        privacyTypeImage.image = viewModel.privacyImage
        privacyLabel.attributedText = viewModel.attributedPrivacyString
    }
}

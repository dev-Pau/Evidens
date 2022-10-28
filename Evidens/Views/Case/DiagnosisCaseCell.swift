//
//  DiagnosisCaseCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/10/22.
//

import UIKit

class DiagnosisCaseCell: UICollectionViewCell {
    
    let cellContentView = UIView()
    
    var updateNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    var imageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "case.privacy")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    var updateTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = lightColor
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
        addSubview(cellContentView)
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        cellContentView.addSubviews(imageView, updateNumberLabel, updateTextLabel, separatorView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: 10),
            imageView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            imageView.heightAnchor.constraint(equalToConstant: 30),
            imageView.widthAnchor.constraint(equalToConstant: 30),
            
            updateNumberLabel.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: 10),
            updateNumberLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            updateNumberLabel.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            
            updateTextLabel.topAnchor.constraint(equalTo: updateNumberLabel.bottomAnchor, constant: 5),
            updateTextLabel.leadingAnchor.constraint(equalTo: updateNumberLabel.leadingAnchor),
            updateTextLabel.trailingAnchor.constraint(equalTo: updateNumberLabel.trailingAnchor),
            updateTextLabel.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        imageView.layer.cornerRadius = 30 / 2
    }
    
    func set(user: User) {
        imageView.sd_setImage(with: URL(string: user.profileImageUrl!))
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        let autoLayoutSize = cellContentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
}

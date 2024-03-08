//
//  ContentReferenceCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/3/24.
//

import UIKit

class ContentReferenceCell: UICollectionViewCell {
    
    var reference: Reference?
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .center
        iv.layer.cornerRadius = 12
        iv.backgroundColor = .systemBackground
        iv.image = UIImage(named: AppStrings.Assets.fillQuote)!.withRenderingMode(.alwaysOriginal).withTintColor(primaryGray).scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25))
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .systemBackground
        
        var size: CGFloat = 75
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor.secondaryLabel.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.cornerRadius = 10
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        
        addSubviews(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.heightAnchor.constraint(equalToConstant: size)
        ])
    }
}

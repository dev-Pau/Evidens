//
//  PendingOnboardingCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/8/23.
//

import UIKit

class FeaturesCell: UICollectionViewCell {
    
    private let titleLabel: UILabel = {
        let label = PrimaryLabel(placeholder: "")
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubviews(titleLabel)
        
        NSLayoutConstraint.activate([
            //titleLabel.topAnchor.constraint(equalTo: <#T##NSLayoutAnchor<NSLayoutYAxisAnchor>#>)
        ])
    }
}

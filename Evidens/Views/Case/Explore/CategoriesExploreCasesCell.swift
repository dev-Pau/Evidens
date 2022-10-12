//
//  CategoriesExploreCasesCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/10/22.
//

import UIKit

class CategoriesExploreCasesCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = lightColor
        layer.cornerRadius = 3
    }
}

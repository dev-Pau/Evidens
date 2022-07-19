//
//  MECaseLabel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/7/22.
//

import UIKit

class METitleCaseLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        
        textColor = .black
        
        font = .systemFont(ofSize: 18, weight: .semibold)
        
        numberOfLines = 1
        
        lineBreakMode = .byTruncatingTail
        
        contentMode = .scaleAspectFit
        
        isUserInteractionEnabled = true
    }
}

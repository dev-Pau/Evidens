//
//  TextField.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/6/22.
//

import UIKit

class MEPostLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        
        textColor = blackColor
        
        font = .systemFont(ofSize: 14, weight: .regular)
        
        numberOfLines = 5
        
        lineBreakMode = .byTruncatingTail
        
        contentMode = .scaleAspectFit
        
        isUserInteractionEnabled = true
    }
}

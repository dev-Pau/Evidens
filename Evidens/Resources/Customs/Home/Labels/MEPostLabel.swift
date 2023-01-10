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
        
        textColor = .label
        
        font = .systemFont(ofSize: 16, weight: .regular)
        
        numberOfLines = 3
        
        lineBreakMode = .byTruncatingTail
        
        contentMode = .scaleAspectFit
        
        isUserInteractionEnabled = true
    }
}

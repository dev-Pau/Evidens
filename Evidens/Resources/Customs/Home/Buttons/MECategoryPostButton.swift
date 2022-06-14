//
//  MECategoryPostButton.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/6/22.
//

import UIKit

class MECategoryPostButton: UIButton {
    
    private var title: String = ""
    private var color: UIColor!
    private var titleColor: UIColor!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    init(title: String, color: UIColor, titleColor: UIColor) {
        super.init(frame: .zero)
        self.title = title
        self.color = color
        self.titleColor = titleColor
        configure()
    }
    
    
    private func configure() {
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        
        backgroundColor = color
        layer.cornerRadius = 11
        
        titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        
        translatesAutoresizingMaskIntoConstraints = false
    }
    
}

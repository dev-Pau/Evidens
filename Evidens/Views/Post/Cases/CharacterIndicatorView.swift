//
//  CharacterIndicatorView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 4/7/22.
//

import UIKit

class CharacterIndicatorView: UIView {
    
    var maxChar: Int = 0
    
    var characterCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    init(maxChar: Int) {
        super.init(frame: .zero)
        self.maxChar = maxChar
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 8
        backgroundColor = UIColor(rgb: 0xD5DBE7)
        characterCountLabel.text = "0/\(maxChar)"
        
        addSubview(characterCountLabel)
        
        NSLayoutConstraint.activate([
            characterCountLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            characterCountLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}

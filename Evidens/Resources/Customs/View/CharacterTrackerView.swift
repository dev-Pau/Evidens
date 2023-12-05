//
//  CharacterTrackerView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/7/22.
//

import UIKit

class CharacterTrackerView: UIView {
    
    private var numberOfCharacters: Int

    private let textTrackerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 13, scaleStyle: .largeTitle, weight: .regular, scales: false)
        label.textColor = primaryColor
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    init(withMaxCharacters numberOfCharacters: Int) {
        self.numberOfCharacters = numberOfCharacters
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        
        textTrackerLabel.text = "0/\(numberOfCharacters)"
        
        addSubview(textTrackerLabel)
        
        NSLayoutConstraint.activate([
            textTrackerLabel.topAnchor.constraint(equalTo: topAnchor),
            textTrackerLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            textTrackerLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            textTrackerLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    
    func updateTextTracking(toValue value: Int) {
        textTrackerLabel.text = "\(value)/\(numberOfCharacters)"
    }
}

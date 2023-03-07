//
//  NewContentViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/3/23.
//

import UIKit

class NewContentCell: UICollectionViewCell {
    
    private let contentNewsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
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
        addSubview(contentNewsLabel)
        NSLayoutConstraint.activate([
            contentNewsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            contentNewsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            contentNewsLabel.topAnchor.constraint(equalTo: topAnchor),
            contentNewsLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        contentNewsLabel.text = "Residents and workers near the site where a train carrying hazardous chemicals derailed this month have been diagnosed with bronchitis and other conditions that doctors and nurses suspect are linked to chemical exposure. Melissa Blake, who lives within a mile of the crash site in East Palestine, Ohio, said she started coughing up gray mucus and was struggling to breathe on Feb. 5, two days after the Norfolk Southern train derailed. That day she evacuated her home and also went to the emergency room, where she was diagnosed with “acute bronchitis due to chemical fumes,” according to medical records reviewed by NBC News. “They gave me a breathing machine. They put me on oxygen. They gave me three types of steroids,” Blake said. She has yet to move back home since being discharged nearly three weeks ago."
    }
}

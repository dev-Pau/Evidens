//
//  MessageSearchCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/6/23.
//

import UIKit

class ToolbarSearchCell: UICollectionViewCell {

    override var isSelected: Bool {
        didSet {
            UIView.transition(with: label, duration: 0.4, options: .transitionCrossDissolve) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.label.textColor = strongSelf.isSelected ? .label : K.Colors.primaryGray
            }
        }
    }
    
    var label: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.addFont(size: 15, scaleStyle: .largeTitle, weight: .bold)
        label.numberOfLines = 0
        label.textColor = K.Colors.primaryGray
        label.translatesAutoresizingMaskIntoConstraints = false
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
        backgroundColor = .clear
        
        addSubviews(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
    
    func set(from startColor: UIColor, to endColor: UIColor, progress: CGFloat) {
        let interpolatedColor = UIColor().interpolateColor(from: startColor, to: endColor, progress: progress)
        label.textColor = interpolatedColor
    }
    
    func setDefault() {
        label.textColor = K.Colors.primaryGray
    }
}

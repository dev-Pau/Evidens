//
//  MEShowMoreView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/4/23.
//

import UIKit

class MEShowMoreView: UIView {
    
    private let showMoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = " MORE"
        label.textColor = primaryColor
        label.backgroundColor = .systemBackground
        //label.backgroundColor = .systemBackground
        label.font = .systemFont(ofSize: 13, weight: .bold)
        return label
    }()
    
    let gradientView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(showMoreLabel, gradientView)
        NSLayoutConstraint.activate([
            showMoreLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            //showMoreLabel.topAnchor.constraint(equalTo: topAnchor),
            showMoreLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            gradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: showMoreLabel.leadingAnchor),
            gradientView.topAnchor.constraint(equalTo: topAnchor),
            gradientView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.systemBackground, UIColor.systemBackground.cgColor]
        gradientLayer.locations = [0, 0.2, 1]
        gradientLayer.frame = gradientView.bounds
        gradientView.layer.mask = gradientLayer
    }
}


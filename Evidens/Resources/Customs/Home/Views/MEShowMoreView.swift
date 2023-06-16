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
        label.text = "...show more"
        label.textColor = .secondaryLabel
        label.backgroundColor = .systemBackground
        //label.backgroundColor = .systemBackground
        label.font = .systemFont(ofSize: 14, weight: .semibold)
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
        addSubviews(showMoreLabel)
        NSLayoutConstraint.activate([
            showMoreLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            showMoreLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}


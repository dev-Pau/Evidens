//
//  MEShowMoreView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/4/23.
//

import UIKit

class ShowMoreView: UIView {
    
    private let showMoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "..." + AppStrings.Miscellaneous.showMore
        label.textColor = .link
        label.backgroundColor = .systemBackground
        label.isUserInteractionEnabled = false
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        addSubviews(showMoreLabel)
        NSLayoutConstraint.activate([
            showMoreLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            showMoreLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


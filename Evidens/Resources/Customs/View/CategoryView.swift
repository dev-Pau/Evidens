//
//  MECategoryView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/7/22.
//

import Foundation
import UIKit

protocol CategoryViewDelegate: AnyObject {
    func didTapCategory(_ view: CategoryView)
}

class CategoryView: UIView {
    
    weak var delegate: CategoryViewDelegate?
    
    private var kind: UserKind
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 17.0, scaleStyle: .title1, weight: .black)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let selectionButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.circle)?.scalePreservingAspectRatio(targetSize: CGSize(width: 24, height: 24)).withTintColor(K.Colors.separatorColor)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        return button
    }()
    
    init(kind: UserKind) {
        self.kind = kind
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        isUserInteractionEnabled = true
        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = K.Colors.separatorColor.cgColor
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor.secondaryLabel.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.cornerRadius = 10
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        
        titleLabel.text = kind.title
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCategoryTap)))
        
        addSubviews(titleLabel, selectionButton)
        
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            
            selectionButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            selectionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            selectionButton.widthAnchor.constraint(equalToConstant: 24),
            selectionButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func resetCategoryView() {
        selectionButton.configuration?.image = UIImage(systemName: AppStrings.Icons.circle)?.scalePreservingAspectRatio(targetSize: CGSize(width: 24, height: 24)).withTintColor(K.Colors.separatorColor)
        layer.borderColor = K.Colors.separatorColor.cgColor
        layer.borderWidth = 1
    }
    
    @objc func handleCategoryTap() {
        delegate?.didTapCategory(self)
        selectionButton.configuration?.image = UIImage(systemName: AppStrings.Icons.checkmarkCircleFill)?.scalePreservingAspectRatio(targetSize: CGSize(width: 24, height: 24)).withTintColor(K.Colors.primaryColor)
        layer.borderColor = K.Colors.primaryColor.cgColor
        layer.borderWidth = 2
    }
}


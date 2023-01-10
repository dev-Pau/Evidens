//
//  MECategoryView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/7/22.
//

import Foundation
import UIKit

protocol MECategoryViewDelegate: AnyObject {
    func didTapCategory(_ view: MECategoryView, completion: @escaping(Bool) -> Void)
}

class MECategoryView: UIView {
    
    weak var delegate: MECategoryViewDelegate?
    
    private var title: String
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let selectionButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "circle")?.scalePreservingAspectRatio(targetSize: CGSize(width: 24, height: 24)).withTintColor(.tertiarySystemGroupedBackground)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        return button
    }()
    
    init(title: String) {
        self.title = title
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
        layer.borderColor = UIColor.quaternarySystemFill.cgColor
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        
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
        selectionButton.configuration?.image = UIImage(systemName: "circle")?.scalePreservingAspectRatio(targetSize: CGSize(width: 24, height: 24)).withTintColor(.quaternarySystemFill)
        layer.borderColor = UIColor.quaternarySystemFill.cgColor
        layer.borderWidth = 1
    }
    
    @objc func handleCategoryTap() {
        delegate?.didTapCategory(self, completion: { completed in
            if completed {
                self.selectionButton.configuration?.image = UIImage(systemName: "checkmark.circle.fill")?.scalePreservingAspectRatio(targetSize: CGSize(width: 24, height: 24)).withTintColor(primaryColor)
                self.layer.borderColor = primaryColor.cgColor
                self.layer.borderWidth = 2
            }
        })
    }
}

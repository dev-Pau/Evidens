//
//  CaseStageView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/7/22.
//

import UIKit

protocol CaseStageViewDelegate: AnyObject {
    func didTapResolved()
}

class CaseStageView: UIView {
    
    weak var delegate: CaseStageViewDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Stage"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = grayColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var unresolvedButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.title = "Unresolved"
        button.configuration?.baseForegroundColor = grayColor
        button.configuration?.baseBackgroundColor = .white
        button.configuration?.background.strokeWidth = 1
        button.configuration?.background.strokeColor = grayColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleUnresolvedTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var resolvedButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.title = "Resolved"
        button.configuration?.baseForegroundColor = grayColor
        button.configuration?.baseBackgroundColor = .white
        button.configuration?.background.strokeWidth = 1
        button.configuration?.background.strokeColor = grayColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleResolvedTap), for: .touchUpInside)
        return button
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillProportionally
        stack.spacing = 10
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(unresolvedButton)
        stackView.addArrangedSubview(resolvedButton)
        addSubviews(titleLabel, stackView)
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),
            titleLabel.widthAnchor.constraint(equalToConstant: 50),
            
            stackView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 30)
            
        ])
    }
    
    @objc func handleResolvedTap() {
        resolvedButton.configuration?.baseBackgroundColor = primaryColor.withAlphaComponent(0.5)
        resolvedButton.configuration?.background.strokeColor = primaryColor
        resolvedButton.configuration?.baseForegroundColor = .white
        resolvedButton.configuration?.image = UIImage(named: "checkmark")!.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)).withTintColor(.white)
        resolvedButton.configuration?.imagePadding = 10
        
        delegate?.didTapResolved()
    }
    
    @objc func handleUnresolvedTap() {
        unresolvedButton.configuration?.baseBackgroundColor = lightColor
        unresolvedButton.configuration?.background.strokeColor = grayColor
        unresolvedButton.configuration?.baseForegroundColor = grayColor
        unresolvedButton.configuration?.image = UIImage(systemName: "magnifyingglass")!.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)).withTintColor(grayColor)
        unresolvedButton.configuration?.imagePadding = 10
    }
}

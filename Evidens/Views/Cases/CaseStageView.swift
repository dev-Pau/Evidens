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

    private lazy var unresolvedButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 12, weight: .semibold)
        button.configuration?.attributedTitle = AttributedString("Unresolved", attributes: container)
        
        button.configuration?.baseForegroundColor = grayColor
        button.configuration?.baseBackgroundColor = .white
        button.configuration?.background.strokeWidth = 1
        button.configuration?.imagePadding = 10
        button.configuration?.image = UIImage(named: "magnifyingglass")?.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)).withTintColor(grayColor)
        button.configuration?.imagePlacement = .leading
        button.configuration?.background.strokeColor = lightGrayColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleUnresolvedTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var resolvedButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 12, weight: .semibold)
        button.configuration?.attributedTitle = AttributedString("Resolved", attributes: container)
        
        button.configuration?.baseForegroundColor = grayColor
        button.configuration?.baseBackgroundColor = .white
        button.configuration?.background.strokeWidth = 1
        button.configuration?.imagePadding = 10
        button.configuration?.image = UIImage(named: "checkmark")?.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)).withTintColor(grayColor)
        button.configuration?.imagePlacement = .leading
        button.configuration?.background.strokeColor = lightGrayColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleResolvedTap), for: .touchUpInside)
        return button
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillEqually
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
        addSubviews(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 35)
        ])
    }
    
    @objc func handleResolvedTap() {
        
        resolvedButton.configuration?.baseBackgroundColor = primaryColor.withAlphaComponent(0.3)
        resolvedButton.configuration?.background.strokeColor = primaryColor
        resolvedButton.configuration?.baseForegroundColor = blackColor
        resolvedButton.configuration?.image = UIImage(named: "checkmark")!.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)).withTintColor(blackColor)
        resolvedButton.configuration?.imagePadding = 10
        resolvedButton.configuration?.background.strokeWidth = 2
        
        delegate?.didTapResolved()
    }
    
    @objc func handleUnresolvedTap() {
        unresolvedButton.configuration?.baseBackgroundColor = lightColor
        unresolvedButton.configuration?.background.strokeColor = grayColor
        unresolvedButton.configuration?.baseForegroundColor = blackColor
        unresolvedButton.configuration?.image = UIImage(named: "magnifyingglass")!.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)).withTintColor(blackColor)
        unresolvedButton.configuration?.imagePadding = 10
        unresolvedButton.configuration?.background.strokeWidth = 2
    }
}

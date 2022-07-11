//
//  CaseStageView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/7/22.
//

import UIKit

protocol CaseStageViewDelegate: AnyObject {
    func didTapResolved()
    func didTapUnresolved()
}

class CaseStageView: UIView {
    
    weak var delegate: CaseStageViewDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Is this case resolved?"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = grayColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var unresolvedButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 17, weight: .regular)
        //button.configuration?.attributedTitle = AttributedString("Unresolved", attributes: container)
        
        button.configuration?.baseForegroundColor = grayColor
        button.configuration?.baseBackgroundColor = .white
        button.configuration?.background.strokeWidth = 1

        button.configuration?.image = UIImage(named: "xmark")?.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)).withTintColor(grayColor)
        button.configuration?.imagePlacement = .leading
        button.configuration?.background.strokeColor = lightGrayColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleUnresolvedTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var resolvedButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 17, weight: .regular)
        //button.configuration?.attributedTitle = AttributedString("Resolved", attributes: container)
        
        button.configuration?.baseForegroundColor = grayColor
        button.configuration?.baseBackgroundColor = .white
        button.configuration?.background.strokeWidth = 1

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
        addSubviews(titleLabel, stackView)
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 35),
            titleLabel.widthAnchor.constraint(equalToConstant: 200),
            
            stackView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 35)
        ])
    }
    
    @objc func handleResolvedTap() {
        
        resolvedButton.configuration?.baseBackgroundColor = primaryColor
        //resolvedButton.configuration?.background.strokeColor = primaryColor
        resolvedButton.configuration?.image = UIImage(named: "checkmark")!.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)).withTintColor(.white)
        resolvedButton.configuration?.imagePadding = 10
        resolvedButton.configuration?.background.strokeWidth = 0
        
        unresolvedButton.configuration?.baseBackgroundColor = .white
        unresolvedButton.configuration?.background.strokeColor = lightGrayColor
        unresolvedButton.configuration?.baseForegroundColor = grayColor
        unresolvedButton.configuration?.image = UIImage(named: "xmark")!.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)).withTintColor(grayColor)
        unresolvedButton.configuration?.background.strokeWidth = 1
        
        resolvedButton.isUserInteractionEnabled = false
        unresolvedButton.isUserInteractionEnabled = true
        
        delegate?.didTapResolved()
    }
    
    @objc func handleUnresolvedTap() {
        //unresolvedButton.configuration?.baseBackgroundColor = lightColor
        unresolvedButton.configuration?.background.strokeColor = .systemYellow
        unresolvedButton.configuration?.baseForegroundColor = blackColor
        unresolvedButton.configuration?.image = UIImage(named: "xmark")!.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)).withTintColor(blackColor)
        unresolvedButton.configuration?.background.strokeWidth = 2
        
        
        resolvedButton.configuration?.baseForegroundColor = grayColor
        resolvedButton.configuration?.baseBackgroundColor = .white
        resolvedButton.configuration?.background.strokeWidth = 1
        resolvedButton.configuration?.image = UIImage(named: "checkmark")?.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)).withTintColor(grayColor)
        resolvedButton.configuration?.background.strokeColor = lightGrayColor
        
        resolvedButton.isUserInteractionEnabled = true
        unresolvedButton.isUserInteractionEnabled = false
        
        delegate?.didTapUnresolved()
    }
}

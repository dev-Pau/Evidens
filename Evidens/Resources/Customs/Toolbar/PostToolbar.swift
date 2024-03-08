//
//  PostAssistantToolbar.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/4/23.
//

import UIKit

protocol PostToolbarDelegate: AnyObject {
    func didTapAddMediaButton()
    func didTapQuoteButton()
}

class PostToolbar: UIToolbar {
    
    weak var toolbarDelegate: PostToolbarDelegate?

    private lazy var addMediaButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.buttonSize = .mini
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.plus, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.white).scalePreservingAspectRatio(targetSize: CGSize(width: 12, height: 12))
        button.configuration?.baseBackgroundColor = primaryColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleAddMediaButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var addReferenceButton: UIButton = {
        let button = UIButton()
        button.configuration = .plain()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.buttonSize = .mini
        button.configuration?.image = UIImage(named: AppStrings.Assets.fillQuote)?.withRenderingMode(.alwaysOriginal).withTintColor(primaryColor).scalePreservingAspectRatio(targetSize: CGSize(width: 23, height: 23))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleAddQuote), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        /*
         let standardAppearance = UINavigationBarAppearance.secondaryAppearance()
         let scrollAppearance = UINavigationBarAppearance.contentAppearance()
         navigationController?.navigationBar.standardAppearance = scrollAppearance
         navigationController?.navigationBar.scrollEdgeAppearance = standardAppearance
         */
        
        let standardAppearance = UIToolbarAppearance()
        standardAppearance.configureWithOpaqueBackground()
        standardAppearance.backgroundColor = .systemBackground
        standardAppearance.shadowColor = .clear
        standardAppearance.shadowImage = nil
        
        let scrollAppearance = UIToolbarAppearance()
        scrollAppearance.configureWithOpaqueBackground()
        scrollAppearance.backgroundColor = .systemBackground
        scrollAppearance.shadowColor = separatorColor

        self.scrollEdgeAppearance = scrollAppearance
        self.standardAppearance = scrollAppearance
        
        addSubviews(addMediaButton, addReferenceButton)
        NSLayoutConstraint.activate([
            addMediaButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            addMediaButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            addMediaButton.heightAnchor.constraint(equalToConstant: 22),
            addMediaButton.widthAnchor.constraint(equalToConstant: 22),
            
            addReferenceButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            addReferenceButton.trailingAnchor.constraint(equalTo: addMediaButton.leadingAnchor, constant: -10),
            addReferenceButton.heightAnchor.constraint(equalToConstant: 22),
            addReferenceButton.widthAnchor.constraint(equalToConstant: 22),
        ])
    }
    
    func handleUpdateMediaButtonInteraction(forNumberOfImages number: Int) {
        addMediaButton.isEnabled = number < 4
    }
    
    func enableImages(_ enable: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.addMediaButton.isEnabled = enable
        }
    }
    
    @objc func handleAddMediaButton() {
        toolbarDelegate?.didTapAddMediaButton()
    }
    
    @objc func handleAddQuote() {
        toolbarDelegate?.didTapQuoteButton()
    }
}

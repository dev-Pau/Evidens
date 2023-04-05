//
//  MESearchMenuFooter.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 5/4/23.
//

import UIKit

protocol MESearchMenuFooterDelegate: AnyObject {
    func handleShowResults(withOption option: String)
}

class MESearchMenuFooter: UICollectionReusableView {
    weak var delegate: MESearchMenuFooterDelegate?
    private var selectedOption: String?

    private lazy var applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 17, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("Show Results", attributes: container)
        button.addTarget(self, action: #selector(handleShowResults), for: .touchUpInside)
        button.configuration?.cornerStyle = .capsule
        button.isEnabled = false
        button.configuration?.baseBackgroundColor = .label
        button.configuration?.baseForegroundColor = .systemBackground
        button.translatesAutoresizingMaskIntoConstraints = false
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
        addSubviews(applyButton)

        NSLayoutConstraint.activate([
            applyButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            applyButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            applyButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            applyButton.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
    
    func disableButton() {
        applyButton.isEnabled = false
    }
    
    func didSelectOption(_ selectedOption: String) {
        self.selectedOption = selectedOption
        applyButton.isEnabled = true
    }
    
    @objc func handleShowResults() {
        guard let selectedOption = selectedOption else { return }
        delegate?.handleShowResults(withOption: selectedOption)
    }
}

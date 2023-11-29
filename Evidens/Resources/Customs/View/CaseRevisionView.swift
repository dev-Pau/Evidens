//
//  CaseRevisionView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/7/22.
//

import UIKit

protocol CaseRevisionViewDelegate: AnyObject {
    func didTapRevisions()
}

class CaseRevisionView: UIView {
    
    weak var delegate: CaseRevisionViewDelegate?

    var revision: CaseRevisionKind? {
        didSet {
            configureWithRevision()
        }
    }
    
    var revisionLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .callout)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let separator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(separator, revisionLabel)
        
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleOpenUpdates)))
        
        NSLayoutConstraint.activate([

            revisionLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            revisionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            revisionLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.4)
        ])
    }
    
    func configureWithRevision() {
        guard let revision = revision else { return }

        let regularFont = UIFont.preferredFont(forTextStyle: .callout)
        
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .callout)
        let heavyFontDescriptor = fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.traits: [
                UIFontDescriptor.TraitKey.weight: UIFont.Weight.semibold.rawValue
            ]
        ])
        
        let boldFont = UIFont(descriptor: heavyFontDescriptor, size: 0)
        
        let keywordAttributes: [NSAttributedString.Key: Any] = [
            .font: boldFont,
            .foregroundColor: UIColor.label
        ]
        
        switch revision {
        
        case .clear:
            break
        case .update:
            let text = AppStrings.Content.Case.Revision.revisionContent

            let attributedString = NSMutableAttributedString(string: text, attributes: keywordAttributes)

            revisionLabel.attributedText = attributedString
            
        case .diagnosis:
            let text = AppStrings.Content.Case.Revision.diagnosisContent

            let attributedString = NSMutableAttributedString(string: text, attributes: keywordAttributes)
            
            revisionLabel.attributedText = attributedString
        }
    }
    
    @objc func handleOpenUpdates() {
        delegate?.didTapRevisions()
    }
}

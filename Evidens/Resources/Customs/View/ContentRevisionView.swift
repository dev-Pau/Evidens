//
//  CaseRevisionView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/7/22.
//

import UIKit

protocol ContentRevisionViewDelegate: AnyObject {
    func didTapRevisions()
}

class ContentRevisionView: UIView {
    
    weak var delegate: ContentRevisionViewDelegate?

    var revision: CaseRevisionKind? {
        didSet {
            configureWithRevision()
        }
    }
    
    var reference: ReferenceKind? {
        didSet {
            configureWithReference()
        }
    }
    
    var revisionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 16, scaleStyle: .title2, weight: .regular)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        separator.heightAnchor.constraint(equalToConstant: 0.3333333333333333).isActive = true
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
            revisionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            revisionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            revisionLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            revisionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func configureWithRevision() {
        guard let revision = revision else { return }
        let boldFont = UIFont.addFont(size: 16, scaleStyle: .title2, weight: .semibold)
        
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
    
    func configureWithReference() {
        guard let _ = reference else { return }
        let boldFont = UIFont.addFont(size: 16, scaleStyle: .title2, weight: .semibold)
        
        let keywordAttributes: [NSAttributedString.Key: Any] = [
            .font: boldFont,
            .foregroundColor: UIColor.label
        ]
        
        let text = AppStrings.Miscellaneous.evidence

        let attributedString = NSMutableAttributedString(string: text, attributes: keywordAttributes)

        revisionLabel.attributedText = attributedString
    }
    
    @objc func handleOpenUpdates() {
        delegate?.didTapRevisions()
    }
}

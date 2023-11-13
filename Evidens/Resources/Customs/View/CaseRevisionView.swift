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
    
    var profileImageView = ProfileImageView(frame: .zero)
    
    var revision: CaseRevisionKind? {
        didSet {
            configureWithRevision()
        }
    }
    
    var revisionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let topSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    private let bottomSeparator: UIView = {
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
        addSubviews(topSeparator, bottomSeparator, profileImageView, revisionLabel)
        
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleOpenUpdates)))
        
        NSLayoutConstraint.activate([
            profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 5),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            profileImageView.heightAnchor.constraint(equalToConstant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 20),
            
            revisionLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            revisionLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            revisionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
            
            topSeparator.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: -5),
            topSeparator.leadingAnchor.constraint(equalTo: leadingAnchor),
            topSeparator.trailingAnchor.constraint(equalTo: trailingAnchor),
            topSeparator.heightAnchor.constraint(equalToConstant: 0.4),
            
            bottomSeparator.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 5),
            bottomSeparator.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomSeparator.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomSeparator.heightAnchor.constraint(equalToConstant: 0.4)
        ])
        
        profileImageView.layer.cornerRadius = 20 / 2
    }
    
    func configureWithRevision() {
        guard let revision = revision else { return }
        
        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15, weight: .regular),
            .foregroundColor: UIColor.secondaryLabel
        ]
        
        let keywordAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15, weight: .semibold),
            .foregroundColor: UIColor.label
        ]
        
        switch revision {
        
        case .clear:
            break
        case .update:
            let text = AppStrings.Content.Case.Revision.revisionContent
            let keyword = AppStrings.Content.Case.Share.revision.lowercased()
            let attributedString = NSMutableAttributedString(string: text, attributes: baseAttributes)
            
            if let range = text.range(of: keyword) {
                attributedString.addAttributes(keywordAttributes, range: NSRange(range, in: text))
            }
            
            revisionLabel.attributedText = attributedString
            
        case .diagnosis:
            let text = AppStrings.Content.Case.Revision.diagnosisContent
            let keyword = AppStrings.Content.Case.Share.diagnosis.lowercased()
            let attributedString = NSMutableAttributedString(string: text, attributes: baseAttributes)
            
            if let range = text.range(of: keyword) {
                attributedString.addAttributes(keywordAttributes, range: NSRange(range, in: text))
            }
            
            revisionLabel.attributedText = attributedString
        }
    }
    
    @objc func handleOpenUpdates() {
        delegate?.didTapRevisions()
    }
}

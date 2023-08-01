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
    
    var diagnosisLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        addSubviews(profileImageView, diagnosisLabel)
        
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleOpenUpdates)))
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            profileImageView.heightAnchor.constraint(equalToConstant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 20),
            
            diagnosisLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            diagnosisLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 5),
            diagnosisLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
        ])
        
        profileImageView.layer.cornerRadius = 20 / 2
    }
    
    func configureWithRevision() {
        guard let revision = revision else { return }
        switch revision {
            
        case .clear:
            break
        case .update:
            diagnosisLabel.text = AppStrings.Content.Case.Revision.revisionContent
        case .diagnosis:
            diagnosisLabel.text = AppStrings.Content.Case.Revision.diagnosisContent
        }
    }
    
    @objc func handleOpenUpdates() {
        delegate?.didTapRevisions()
    }
}

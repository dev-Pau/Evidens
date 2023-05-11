//
//  CaseFeedTextCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/4/23.
//

import UIKit

class CaseFeedTextCell: UICollectionViewCell {
    
    var viewModel: CaseViewModel? {
        didSet { configure() }
    }
    
    weak var delegate: CaseCellDelegate?
    
    private var user: User?
    
    private lazy var dotsImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
        button.configuration?.baseForegroundColor = .white
        button.configuration?.buttonSize = .small
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        return button
    }()
    
    private let caseTimestampLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .white
        return label
    }()
    
    private let caseTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 23, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.textColor = .white
        return label
    }()
    
    private let caseTitleBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let caseProfessionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.textColor = .white
        return label
    }()
    
    private let caseTagsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.textColor = .white
        return label
    }()
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.layer.borderWidth = 2
        iv.layer.borderColor = UIColor.white.cgColor
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = .white
        return label
    }()
    
    private let caseDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10

        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileTap)))
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapClinicalCase)))

        addSubviews(caseTitleBackgroundView, dotsImageButton, caseTimestampLabel, caseProfessionLabel, caseTitleLabel, caseTagsLabel, profileImageView, fullNameLabel, caseDescriptionLabel)
        
        NSLayoutConstraint.activate([
            dotsImageButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            dotsImageButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            
            caseTimestampLabel.centerYAnchor.constraint(equalTo: dotsImageButton.centerYAnchor),
            caseTimestampLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            caseTimestampLabel.trailingAnchor.constraint(equalTo: dotsImageButton.leadingAnchor, constant: -10),
            
            caseTitleLabel.topAnchor.constraint(equalTo: caseTimestampLabel.bottomAnchor, constant: 20),
            caseTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            caseTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            caseProfessionLabel.topAnchor.constraint(equalTo: caseTitleLabel.bottomAnchor, constant: 20),
            caseProfessionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            caseProfessionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            caseTagsLabel.topAnchor.constraint(equalTo: caseProfessionLabel.bottomAnchor, constant: 10),
            caseTagsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            caseTagsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            profileImageView.topAnchor.constraint(equalTo: caseTagsLabel.bottomAnchor, constant: 20),
            profileImageView.leadingAnchor.constraint(equalTo: caseTagsLabel.leadingAnchor),
            profileImageView.heightAnchor.constraint(equalToConstant: 30),
            profileImageView.widthAnchor.constraint(equalToConstant: 30),
            
            fullNameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            fullNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            fullNameLabel.trailingAnchor.constraint(equalTo: caseTagsLabel.trailingAnchor),

            caseDescriptionLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            caseDescriptionLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            caseDescriptionLabel.trailingAnchor.constraint(equalTo: fullNameLabel.trailingAnchor),
            caseDescriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15),
            
            caseTitleBackgroundView.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: -10),
            caseTitleBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            caseTitleBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            caseTitleBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor)
             
        ])
        
        caseTitleBackgroundView.layer.cornerRadius = layer.cornerRadius
        profileImageView.layer.cornerRadius = 30 / 2
    }
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        caseTimestampLabel.text = viewModel.caseInfoString.joined(separator: " • ")
        caseTitleLabel.text = viewModel.caseTitle
        caseTagsLabel.text = viewModel.caseTypeDetails.joined(separator: " • ")
        caseDescriptionLabel.text = viewModel.caseDescription
        caseProfessionLabel.text = viewModel.caseProfessions.joined(separator: " • ")
        backgroundColor = viewModel.caseBackgroundColor
        dotsImageButton.menu = addMenuItems()
        
        if viewModel.caseIsAnonymous {
            profileImageView.image = UIImage(named: "user.profile.privacy")?.withTintColor(viewModel.caseBackgroundColor)
            fullNameLabel.text = "Anonymous Case"
        } else {
            profileImageView.image = UIImage(named: "user.profile")
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
            if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                layer.borderColor = UIColor.quaternarySystemFill.cgColor
            }
        }
    }
    
    func set(user: User) {
        guard let viewModel = viewModel else { return }
        self.user = user
        
        if let imageUrl = user.profileImageUrl, imageUrl != "", !viewModel.caseIsAnonymous {
            profileImageView.sd_setImage(with: URL(string: imageUrl))
        }
        
        fullNameLabel.text = user.firstName! + " " + user.lastName! + " • " + user.profession!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addMenuItems() -> UIMenu? {
        guard let viewModel = viewModel else { return nil }
        //  Not owner
        let menuItems = UIMenu(title: "", subtitle: "", image: nil, identifier: nil, options: .displayInline, children: [
            UIAction(title: Case.CaseMenuOptions.report.rawValue, image: Case.CaseMenuOptions.report.menuOptionsImage, handler: { (_) in
                self.delegate?.clinicalCase(self, didTapMenuOptionsFor: viewModel.clinicalCase, option: .report)
            })
        ])
        dotsImageButton.showsMenuAsPrimaryAction = true
        return menuItems
    }
    
    @objc func handleProfileTap() {
        guard let user = user, let viewModel = viewModel, !viewModel.caseIsAnonymous else { return }
        delegate?.clinicalCase(self, wantsToShowProfileFor: user)
    }
    
    @objc func didTapClinicalCase() {
        guard let viewModel = viewModel, let user = user else { return }
        delegate?.clinicalCase(self, wantsToSeeCase: viewModel.clinicalCase, withAuthor: user)
    }
}


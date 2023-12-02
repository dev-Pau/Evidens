//
//  CasesFeedTextImageCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/4/23.
//

import UIKit

class PrimaryCaseImageCell: UICollectionViewCell {
    
    var viewModel: CaseViewModel? {
        didSet { configure() }
    }
    
    weak var delegate: CaseCellDelegate?
    
    private var user: User?
    
    private let caseImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .quaternarySystemFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    private let ellipsisButton = EllipsisButton(type: .system)
   
    private let timestampLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.addFont(size: 14.0, scaleStyle: .largeTitle, weight: .regular)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingMiddle
        label.textColor = .white
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()

        label.font = UIFont.addFont(size: 23.0, scaleStyle: .title1, weight: .heavy)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.textColor = .white
        return label
    }()
    
    private let baseBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let disciplinesLabel: UILabel = {
        let label = UILabel()

        label.font = UIFont.addFont(size: 14.0, scaleStyle: .largeTitle, weight: .semibold)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.textColor = .white
        return label
    }()
    
    private let itemsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 14.0, scaleStyle: .largeTitle, weight: .regular)
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
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 14.0, scaleStyle: .largeTitle, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = .label
        return label
    }()
    
    private let separator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()

    private let contentTextView = PrimaryCaseTextView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10

        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileTap)))
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapClinicalCase)))
        
        addSubviews(baseBackgroundView, ellipsisButton, timestampLabel, disciplinesLabel, titleLabel, itemsLabel, profileImageView, nameLabel, contentTextView, caseImageView, separator)
        
        ellipsisButton.sizeToFit()
        
        NSLayoutConstraint.activate([
            ellipsisButton.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            ellipsisButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            ellipsisButton.widthAnchor.constraint(equalToConstant: 30),
            
            timestampLabel.centerYAnchor.constraint(equalTo: ellipsisButton.centerYAnchor),
            timestampLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            timestampLabel.trailingAnchor.constraint(equalTo: ellipsisButton.leadingAnchor, constant: -10),
            
            titleLabel.topAnchor.constraint(equalTo: timestampLabel.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            disciplinesLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            disciplinesLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            disciplinesLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            itemsLabel.topAnchor.constraint(equalTo: disciplinesLabel.bottomAnchor, constant: 10),
            itemsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            itemsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            profileImageView.topAnchor.constraint(equalTo: itemsLabel.bottomAnchor, constant: 20),
            profileImageView.leadingAnchor.constraint(equalTo: itemsLabel.leadingAnchor),
            profileImageView.heightAnchor.constraint(equalToConstant: 30),
            profileImageView.widthAnchor.constraint(equalToConstant: 30),
            
            nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: itemsLabel.trailingAnchor),

            contentTextView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            contentTextView.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            contentTextView.trailingAnchor.constraint(equalTo: caseImageView.leadingAnchor, constant: -10),
            contentTextView.bottomAnchor.constraint(equalTo: caseImageView.bottomAnchor),
            
            baseBackgroundView.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: -10),
            baseBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            baseBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            baseBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            separator.topAnchor.constraint(equalTo: baseBackgroundView.topAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.4),
            
            caseImageView.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            caseImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            caseImageView.heightAnchor.constraint(equalToConstant: 100),
            caseImageView.widthAnchor.constraint(equalToConstant: 100),
            caseImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
        
        layer.borderWidth = 0.4
        layer.borderColor = separatorColor.cgColor

        caseImageView.layer.cornerRadius = layer.cornerRadius
        baseBackgroundView.layer.cornerRadius = layer.cornerRadius
        profileImageView.layer.cornerRadius = 30 / 2
    }
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        backgroundColor = viewModel.baseColor
        
        timestampLabel.text = viewModel.details.joined(separator: AppStrings.Characters.dot)
        titleLabel.text = viewModel.title
        itemsLabel.text = viewModel.items.map { $0.title }.joined(separator: AppStrings.Characters.dot)
        disciplinesLabel.text = viewModel.disciplines.map { $0.name }.joined(separator: AppStrings.Characters.dot)

        contentTextView.text = viewModel.content
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTextViewTap(_:)))
        contentTextView.addGestureRecognizer(gestureRecognizer)
        contentTextView.addHashtags(withColor: .link)
        contentTextView.delegate = self
     
        ellipsisButton.menu = addMenuItems()
        if let firstImage = viewModel.images.first {
            caseImageView.sd_setImage(with: URL(string: firstImage))
        }
        
        if viewModel.anonymous {
            profileImageView.image = UIImage(named: AppStrings.Assets.privacyProfile)?.withTintColor(viewModel.baseColor)
            nameLabel.text = AppStrings.Content.Case.Privacy.anonymousCase
        } else {
            profileImageView.image = UIImage(named: AppStrings.Assets.profile)
            if let user = user, let imageUrl = user.profileUrl, imageUrl != "" {
                profileImageView.sd_setImage(with: URL(string: imageUrl))
            }
        }
    }
    
    func set(user: User) {
        guard let viewModel = viewModel else { return }
        self.user = user
        
        if let imageUrl = user.profileUrl, imageUrl != "", !viewModel.anonymous {
            profileImageView.sd_setImage(with: URL(string: imageUrl))
        }
        
        nameLabel.text = user.name()
    }
    
    func anonymize() {
        self.user = nil
        profileImageView.image = UIImage(named: AppStrings.Assets.privacyProfile)
        nameLabel.text = AppStrings.Content.Case.Privacy.anonymousCase
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addMenuItems() -> UIMenu? {
        guard let viewModel = viewModel, let delegate = delegate else { return nil }

        if let menu = UIMenu.createPrimaryCaseMenu(self, for: viewModel, delegate: delegate) {
            ellipsisButton.showsMenuAsPrimaryAction = true
            return menu
        }
        return nil
    }
    
    @objc func handleProfileTap() {
        guard let user = user, let viewModel = viewModel, !viewModel.anonymous else { return }
        delegate?.clinicalCase(self, wantsToShowProfileFor: user)
    }
    
    @objc func didTapClinicalCase() {
        guard let viewModel = viewModel else { return }
        delegate?.clinicalCase(self, wantsToSeeCase: viewModel.clinicalCase, withAuthor: user)
    }
    
    @objc func handleTextViewTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: contentTextView)
        let position = contentTextView.closestPosition(to: location)!

        if let range = contentTextView.tokenizer.rangeEnclosingPosition(position, with: .character, inDirection: .layout(.left)) {
            let startIndex = contentTextView.offset(from: contentTextView.beginningOfDocument, to: range.start)
            _ = contentTextView.offset(from: contentTextView.beginningOfDocument, to: range.end)

            let attributes = contentTextView.attributedText.attributes(at: startIndex, effectiveRange: nil)
            
            if attributes.keys.contains(.link), let hashtag = attributes[.link] as? String {
                delegate?.clinicalCase(wantsToSeeHashtag: hashtag)
            } else {
                didTapClinicalCase()
            }
        }
    }
}
    
extension PrimaryCaseImageCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return false
    }
}

extension PrimaryCaseImageCell: CaseCellProtocol { }



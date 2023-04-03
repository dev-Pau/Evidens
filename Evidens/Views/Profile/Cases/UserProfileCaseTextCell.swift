//
//  UserProfileCaseTextCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/8/22.
//

import UIKit

class UserProfileCaseTextCell: UICollectionViewCell {
    
    var viewModel: CaseViewModel? {
        didSet { configure() }
    }
    
    var user: User?

    private let caseStateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleCaseLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionCaseLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let likesButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "heart.fill")?.scalePreservingAspectRatio(targetSize: CGSize(width: 12, height: 12)).withRenderingMode(.alwaysOriginal).withTintColor(pinkColor)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let likesCommentsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let caseLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .quaternarySystemFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        backgroundColor = .systemBackground
        addSubviews(titleCaseLabel, caseStateLabel, descriptionCaseLabel, likesButton, likesCommentsLabel, caseLabel, separatorView)
        
        NSLayoutConstraint.activate([
            caseLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            caseLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),

            caseStateLabel.topAnchor.constraint(equalTo: caseLabel.bottomAnchor, constant: 2),
            caseStateLabel.leadingAnchor.constraint(equalTo: caseLabel.leadingAnchor),
            
            titleCaseLabel.topAnchor.constraint(equalTo: caseStateLabel.bottomAnchor, constant: 8),
            titleCaseLabel.leadingAnchor.constraint(equalTo: caseLabel.leadingAnchor),
            titleCaseLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            descriptionCaseLabel.topAnchor.constraint(equalTo: titleCaseLabel.bottomAnchor, constant: 5),
            descriptionCaseLabel.leadingAnchor.constraint(equalTo: titleCaseLabel.leadingAnchor),
            descriptionCaseLabel.trailingAnchor.constraint(equalTo: titleCaseLabel.trailingAnchor),
            descriptionCaseLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            likesCommentsLabel.topAnchor.constraint(equalTo: caseLabel.topAnchor),
            likesCommentsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            likesButton.centerYAnchor.constraint(equalTo: likesCommentsLabel.centerYAnchor),
            likesButton.trailingAnchor.constraint(equalTo: likesCommentsLabel.leadingAnchor, constant: -2),
            likesButton.widthAnchor.constraint(equalToConstant: 12),
            likesButton.heightAnchor.constraint(equalToConstant: 12),

            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        titleCaseLabel.text = viewModel.caseTitle
        descriptionCaseLabel.text = viewModel.caseDescription
        caseLabel.attributedText = caseLabelAttributedString()
        likesCommentsLabel.text = viewModel.likesCommentsText
        likesButton.isHidden = viewModel.likesButtonIsHidden
        caseStateLabel.attributedText = caseStageAttributedString()
    }
    
    func caseStageAttributedString() -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: viewModel!.caseStageString + ". ", attributes: [.font: UIFont.systemFont(ofSize: 13, weight: .semibold), .foregroundColor: UIColor.secondaryLabel])
        attributedText.append(NSAttributedString(string: viewModel!.caseTypeDetails.joined(separator: "•"), attributes: [.font: UIFont.systemFont(ofSize: 13, weight: .regular), .foregroundColor: UIColor.secondaryLabel]))
        return attributedText
    }
    
    func caseLabelAttributedString() -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: user!.firstName! + " " + user!.lastName!, attributes: [.font: UIFont.systemFont(ofSize: 13, weight: .semibold), .foregroundColor: UIColor.secondaryLabel])
        attributedText.append(NSAttributedString(string: " shared this • \(viewModel!.timestampString!)", attributes: [.font: UIFont.systemFont(ofSize: 13, weight: .regular), .foregroundColor: UIColor.secondaryLabel]))
        return attributedText
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        let autoLayoutSize = systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
}


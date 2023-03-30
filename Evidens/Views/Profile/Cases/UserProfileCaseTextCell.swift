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
    
    private lazy var caseStateButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.buttonSize = .mini
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 10, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("Solved", attributes: container)
        button.configuration?.baseForegroundColor = .white
        button.configuration?.baseBackgroundColor = primaryColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleCaseLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.numberOfLines = 1
        //label.text = "The title is a summary of the abstract itself and should convince the reader that the topic is important"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionCaseLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 3
        //label.text = "Clinical narratives represent the main form of communication within health care, providing a personalized account of patient history and assessments, and offering rich information for clinical decision making. Natural language processing (NLP) has repeatedly demonstrated its feasibility"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let likesButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "heart.fill")?.scalePreservingAspectRatio(targetSize: CGSize(width: 12, height: 12)).withRenderingMode(.alwaysOriginal).withTintColor(pinkColor)
        //button.configuration?.baseForegroundColor = pinkColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let likesCommentsLabel: UILabel = {
        let label = UILabel()
        //label.text = "24 · 36 comments"
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        //label.text = "3h ago"
        label.font = .systemFont(ofSize: 12, weight: .regular)
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
        addSubviews(caseStateButton, titleCaseLabel, descriptionCaseLabel, likesButton, likesCommentsLabel, timeLabel, separatorView)
        
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            timeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            
            caseStateButton.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            caseStateButton.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 10),
            
            titleCaseLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 10),
            titleCaseLabel.leadingAnchor.constraint(equalTo: timeLabel.leadingAnchor),
            titleCaseLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            descriptionCaseLabel.topAnchor.constraint(equalTo: titleCaseLabel.bottomAnchor, constant: 5),
            descriptionCaseLabel.leadingAnchor.constraint(equalTo: titleCaseLabel.leadingAnchor),
            descriptionCaseLabel.trailingAnchor.constraint(equalTo: titleCaseLabel.trailingAnchor),
            descriptionCaseLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            likesCommentsLabel.topAnchor.constraint(equalTo: timeLabel.topAnchor),
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
        timeLabel.text = viewModel.timestampString
        likesCommentsLabel.text = viewModel.likesCommentsText
        likesButton.isHidden = viewModel.likesButtonIsHidden
        
        caseStateButton.configuration?.attributedTitle = viewModel.caseStage
        caseStateButton.configuration?.baseBackgroundColor = viewModel.caseStageBackgroundColor
        caseStateButton.configuration?.baseForegroundColor = viewModel.caseStageTextColor
        
        
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


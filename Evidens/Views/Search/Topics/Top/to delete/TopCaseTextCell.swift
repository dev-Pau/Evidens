//
//  TopCaseTextCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/8/22.
//

import UIKit

class TopCaseTextCell: UITableViewCell {
    
    //MARK: - Properties
    
    var viewModel: CaseViewModel? {
        didSet {
            configure()
        }
    }
    
    private lazy var caseStateButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.buttonSize = .mini
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var userPostView = MEUserPostView()
    
    private let titleCaseLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.numberOfLines = 1
        //label.text = "The title is a summary of the abstract itself and should convince the reader that the topic is important"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionCaseLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 15, weight: .regular)
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
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.textColor = .secondaryLabel

        return label
    }()
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubviews(caseStateButton, userPostView, titleCaseLabel, descriptionCaseLabel, likesButton, likesCommentsLabel)
        
        NSLayoutConstraint.activate([
            caseStateButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            caseStateButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            
            userPostView.topAnchor.constraint(equalTo: caseStateButton.bottomAnchor),
            userPostView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            userPostView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            userPostView.heightAnchor.constraint(equalToConstant: 67),
            
            titleCaseLabel.topAnchor.constraint(equalTo: userPostView.bottomAnchor),
            titleCaseLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleCaseLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            descriptionCaseLabel.topAnchor.constraint(equalTo: titleCaseLabel.bottomAnchor),
            descriptionCaseLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            descriptionCaseLabel.trailingAnchor.constraint(equalTo: titleCaseLabel.trailingAnchor),
            
            likesButton.topAnchor.constraint(equalTo: descriptionCaseLabel.bottomAnchor, constant: 3),
            likesButton.leadingAnchor.constraint(equalTo: descriptionCaseLabel.leadingAnchor),
            likesButton.widthAnchor.constraint(equalToConstant: 12),
            likesButton.heightAnchor.constraint(equalToConstant: 12),
            
            likesCommentsLabel.centerYAnchor.constraint(equalTo: likesButton.centerYAnchor),
            likesCommentsLabel.leadingAnchor.constraint(equalTo: likesButton.trailingAnchor, constant: 2),
            likesCommentsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            likesCommentsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)

        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    func configure() {
        guard let viewModel = viewModel else { return }
        /*
        userPostView.usernameLabel.text = viewModel.fullName
        
        if viewModel.userProfileImageUrl != nil {
            userPostView.profileImageView.sd_setImage(with: URL(string: viewModel.userProfileImageUrl!))
        } else {
            userPostView.profileImageView.image = UIImage(systemName: "hand.raised.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(grayColor)
        }
        */
        userPostView.postTimeLabel.text = viewModel.timestampString
        //userPostView.userInfoCategoryLabel.attributedText = viewModel.userInfo
        
        titleCaseLabel.text = viewModel.title
        descriptionCaseLabel.text = viewModel.content
        likesCommentsLabel.text = viewModel.likesCommentsText
        likesButton.isHidden = viewModel.likesButtonIsHidden
        
        caseStateButton.configuration?.attributedTitle = viewModel.caseStage
        caseStateButton.configuration?.baseBackgroundColor = viewModel.caseStageBackgroundColor
        caseStateButton.configuration?.baseForegroundColor = viewModel.caseStageTextColor
    }
}


//
//  UserProfileCaseImageCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 29/7/22.
//

import UIKit

class UserProfileCaseImageCell: UICollectionViewCell {
    
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
        
        button.configuration?.baseBackgroundColor = primaryColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleCaseLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.numberOfLines = 1
        //label.text = "The title is a summary of the abstract itself and should convince the reader that the topic is important"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionCaseLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 3
        //label.text = "Clinical narratives represent the main form of communication within health care, providing a personalized account of patient history and assessments, and offering rich information for clinical decision making. Natural language processing (NLP) has repeatedly demonstrated its feasibility"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let caseImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 5
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .gray
        return iv
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
        label.textColor = grayColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        //label.text = "3h ago"
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 0
        label.textColor = grayColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = lightGrayColor
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
        backgroundColor = .white
        addSubviews(caseStateButton, titleCaseLabel, descriptionCaseLabel, caseImageView, likesButton, likesCommentsLabel, timeLabel, separatorView)
        
        NSLayoutConstraint.activate([
            
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            timeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            
            caseStateButton.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            caseStateButton.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 10),
            
            caseImageView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 10),
            caseImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            caseImageView.heightAnchor.constraint(equalToConstant: 75),
            caseImageView.widthAnchor.constraint(equalToConstant: 75),
            
            titleCaseLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 10),
            titleCaseLabel.leadingAnchor.constraint(equalTo: timeLabel.leadingAnchor),
            titleCaseLabel.trailingAnchor.constraint(equalTo: caseImageView.leadingAnchor, constant: -10),
            
            descriptionCaseLabel.topAnchor.constraint(equalTo: titleCaseLabel.bottomAnchor, constant: 5),
            descriptionCaseLabel.leadingAnchor.constraint(equalTo: titleCaseLabel.leadingAnchor),
            descriptionCaseLabel.trailingAnchor.constraint(equalTo: titleCaseLabel.trailingAnchor),
            
            likesButton.topAnchor.constraint(equalTo: caseImageView.bottomAnchor, constant: 10),
            likesButton.leadingAnchor.constraint(equalTo: titleCaseLabel.leadingAnchor),
            likesButton.widthAnchor.constraint(equalToConstant: 12),
            likesButton.heightAnchor.constraint(equalToConstant: 12),
            
            likesCommentsLabel.centerYAnchor.constraint(equalTo: likesButton.centerYAnchor),
            likesCommentsLabel.leadingAnchor.constraint(equalTo: likesButton.trailingAnchor, constant: 2),
            likesCommentsLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            likesCommentsLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])
    }
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        titleCaseLabel.text = viewModel.caseTitle
        descriptionCaseLabel.text = viewModel.caseDescription
        caseImageView.sd_setImage(with: viewModel.caseImageUrl?.first)
        timeLabel.text = viewModel.timestampString
        likesCommentsLabel.text = viewModel.likesCommentsText
        likesButton.isHidden = viewModel.likesButtonIsHidden
        
        caseStateButton.configuration?.attributedTitle = viewModel.caseStage
        caseStateButton.configuration?.baseBackgroundColor = viewModel.caseStageBackgroundColor
        caseStateButton.configuration?.baseForegroundColor = viewModel.caseStageTextColor
        
    }
}

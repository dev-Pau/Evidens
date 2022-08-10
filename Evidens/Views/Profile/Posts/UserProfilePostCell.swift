//
//  UserProfilePostCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 28/7/22.
//

import UIKit

class UserProfilePostCell: UICollectionViewCell {
    
    var viewModel: PostViewModel? {
        didSet {
            configure()
        }
    }
    
    private var postTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Clinical narratives represent the main form of communication within health care, providing a personalized account of patient history and assessments, and offering rich information for clinical decision making. Natural language processing (NLP) has repeatedly demonstrated its feasibility"
        label.textColor = .black
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 3
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
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = grayColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "3h ago"
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 0
        label.textColor = grayColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = lightGrayColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //image of post if it has
    //text of post to show x lines
    //time slot
    
    //likes and comments
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        backgroundColor = .white
        
        addSubviews(postTextLabel, likesButton, likesCommentsLabel, timeLabel, separatorView)
        
        NSLayoutConstraint.activate([
            
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            timeLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10),
            timeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            
            postTextLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 10),
            postTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            postTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            likesButton.topAnchor.constraint(equalTo: postTextLabel.bottomAnchor, constant: 10),
            likesButton.leadingAnchor.constraint(equalTo: postTextLabel.leadingAnchor),
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
        postTextLabel.text = viewModel.postText
        timeLabel.text = viewModel.timestampString! + " ago"
        likesCommentsLabel.text = viewModel.likesCommentsText
        likesButton.isHidden = viewModel.likesButtonIsHidden
    }
}


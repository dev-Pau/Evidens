//
//  UserProfilePostCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/7/22.
//

import UIKit

class UserProfilePostImageCell: UICollectionViewCell {
    
    var viewModel: PostViewModel? {
        didSet {
            configure()
        }
    }
    
    private var postTextLabel: UILabel = {
        let label = UILabel()
        //label.text = "Clinical narratives represent the main form of communication within health care, providing a personalized account of patient history and assessments, and offering rich information for clinical decision making. Natural language processing (NLP) has repeatedly demonstrated its feasibility"
        label.textColor = .black
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let postImage: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 5
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = lightGrayColor
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
        label.text = "24 · 36 comments"
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
        
        
        
        addSubviews(postTextLabel, postImage, likesButton, likesCommentsLabel, timeLabel, separatorView)
        
        NSLayoutConstraint.activate([
            
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            postImage.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10),
            postImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            postImage.widthAnchor.constraint(equalToConstant: 75),
            postImage.heightAnchor.constraint(equalToConstant: 75),
            
            timeLabel.topAnchor.constraint(equalTo: postImage.topAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            timeLabel.trailingAnchor.constraint(equalTo: postImage.leadingAnchor, constant: -10),
            
            postTextLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 5),
            postTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            postTextLabel.trailingAnchor.constraint(equalTo: postImage.leadingAnchor, constant: -10),
            
            likesButton.topAnchor.constraint(equalTo: postImage.bottomAnchor, constant: 3),
            likesButton.leadingAnchor.constraint(equalTo: postTextLabel.leadingAnchor),
            likesButton.widthAnchor.constraint(equalToConstant: 12),
            likesButton.heightAnchor.constraint(equalToConstant: 12),
            
            likesCommentsLabel.centerYAnchor.constraint(equalTo: likesButton.centerYAnchor),
            likesCommentsLabel.leadingAnchor.constraint(equalTo: likesButton.trailingAnchor, constant: 2),
            likesCommentsLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            likesCommentsLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)

        ])
        
    }
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        postTextLabel.text = viewModel.postText
        postImage.sd_setImage(with: viewModel.postImageUrl.first)
        timeLabel.text = viewModel.timestampString! + " ago"
        likesCommentsLabel.text = viewModel.likesCommentsText
        likesButton.isHidden = viewModel.likesButtonIsHidden
        
    }
}

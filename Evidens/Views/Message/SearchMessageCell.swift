//
//  SearchMessageCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 4/6/23.
//

import UIKit

class SearchMessageCell: UICollectionViewCell {
    
    var viewModel: MessageViewModel? {
        didSet {
            configureWithMessage()
        }
    }
    
    var searchedText = ""

    private let profileImageView = ProfileImageView(frame: .zero)
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubviews(profileImageView, nameLabel, dateLabel, messageLabel)
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            profileImageView.heightAnchor.constraint(equalToConstant: 35),
            profileImageView.widthAnchor.constraint(equalToConstant: 35),
            
            nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            
            dateLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            
            messageLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            messageLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 5),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
        
        profileImageView.heightAnchor.constraint(equalToConstant: 35).priority = .required
    }
    
    private func configureWithMessage() {
        guard let viewModel = viewModel else { return }
        let attrString = NSMutableAttributedString(string: viewModel.text, attributes: [.foregroundColor: UIColor.secondaryLabel])

        let options: NSString.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
        let range = (viewModel.text as NSString).range(of: searchedText, options: options)

        attrString.addAttributes([.foregroundColor: UIColor.label, .font: UIFont.systemFont(ofSize: 15, weight: .medium)], range: range)
        
        let senderString = NSMutableAttributedString(string: AppStrings.Miscellaneous.you + ": ", attributes: [.foregroundColor: UIColor.secondaryLabel])
        
        if viewModel.isSender {
            senderString.append(attrString)
            messageLabel.attributedText = senderString
        } else {
            messageLabel.attributedText = attrString
        }
       
        dateLabel.text = AppStrings.Characters.dot + viewModel.sentDateString
    }
    
    func set(conversation: Conversation?) {
        guard let conversation = conversation else { return }
        let viewModel = ConversationViewModel(conversation: conversation)
        
        if let url = viewModel.image() {
            profileImageView.sd_setImage(with: url)
        } else {
            profileImageView.image = UIImage(named: AppStrings.Assets.profile)
        }
        
        nameLabel.text = viewModel.name
    }
}

//
//  MessagePhotoCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 8/6/23.
//

import UIKit
import SDWebImage

protocol MessagePhotoCellDelegate: AnyObject {
    func didTapMenu(_ option: MessageMenu)
    func didLoadPhoto()
}

class MessagePhotoCell: UICollectionViewCell {
    weak var delegate: MessagePhotoCellDelegate?
    private var bubbleLeadingConstraint: NSLayoutConstraint?
    private var bubbleTrailingConstraint: NSLayoutConstraint?
    private var imageHeightConstraint: NSLayoutConstraint?
    private var bubbleViewBottomAnchor: NSLayoutConstraint?
    
    private var timeLeadingConstriant: NSLayoutConstraint!
    private var timeTrailingConstraint: NSLayoutConstraint!
    var isLastItem: Bool = false
    
    var viewModel: MessageViewModel? {
        didSet {
            configureWithMessage()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bubbleLeadingConstraint?.isActive = false
        bubbleTrailingConstraint?.isActive = false
        imageHeightConstraint?.isActive = false
        timeLeadingConstriant.isActive = false
        timeTrailingConstraint.isActive = false
        bubbleViewBottomAnchor?.isActive = false
    }
    
    private lazy var timestampLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 11, weight: .regular)
        return label
    }()
    
    let messageImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        iv.backgroundColor = .secondaryLabel
        iv.image = UIImage()
        return iv
    }()
    
    /// Initializes a new instance of the view with the specified frame.
    ///
    /// - Parameters:
    ///   - frame: The frame rectangle for the view, measured in points.
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        guard let viewModel = viewModel, let image = viewModel.image else { return }

        var width: CGFloat = 0
        var height: CGFloat = 0
        
        let photoAspectRatio = image.size.width / image.size.height
        width = UIScreen.main.bounds.width - 110
        
        height = min(width / photoAspectRatio, UIScreen.main.bounds.width - 40)
        
        imageHeightConstraint = messageImageView.heightAnchor.constraint(equalToConstant: height)
        imageHeightConstraint?.priority = .defaultHigh
        
        addSubviews(timestampLabel, messageImageView, timeLabel)
        
        if viewModel.isSender {
            messageImageView.backgroundColor = .systemGray3
            bubbleTrailingConstraint = messageImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
            bubbleLeadingConstraint = messageImageView.widthAnchor.constraint(equalToConstant: width)
            
            timeTrailingConstraint = timeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
            timeLeadingConstriant = bubbleLeadingConstraint
            
        } else {
            messageImageView.backgroundColor = .systemGray3
            bubbleLeadingConstraint = messageImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
            bubbleTrailingConstraint = messageImageView.widthAnchor.constraint(equalToConstant: width)
            
            timeLeadingConstriant = timeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
            timeTrailingConstraint = bubbleTrailingConstraint
        }
        
        bubbleViewBottomAnchor = messageImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        
        NSLayoutConstraint.activate([
            timestampLabel.topAnchor.constraint(equalTo: topAnchor),
            timestampLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            timestampLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            messageImageView.topAnchor.constraint(equalTo: timestampLabel.bottomAnchor),
            bubbleTrailingConstraint!,
            imageHeightConstraint!,
            bubbleLeadingConstraint!,
            bubbleViewBottomAnchor!,
            
            timeLeadingConstriant,
            timeTrailingConstraint,
            timeLabel.topAnchor.constraint(equalTo: messageImageView.bottomAnchor),
        ])

        messageImageView.layer.cornerRadius = 17
        
        messageImageView.sd_setImage(with: viewModel.imageUrl) { [weak self] (_, _, _, _) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                // Update content size and scroll to the last item
                if strongSelf.isLastItem {
                    strongSelf.delegate?.didLoadPhoto()
                }
              
            }
        }
        timeLabel.text = viewModel.time
        
        let contextMenu = UIContextMenuInteraction(delegate: self)
        
        messageImageView.addInteraction(contextMenu)
    }
    
    private func configureWithMessage() {
        configure()
    }
    
    func displayTimestamp(_ display: Bool) {
        guard let viewModel = viewModel else { return }
        if display {
            timestampLabel.text = "\(viewModel.date)" + "\n"

        } else {
            timestampLabel.text = nil
        }
    }
    
    func displayTime(_ display: Bool) {
        bubbleViewBottomAnchor?.constant = display ? -13 : 0
        timeLabel.isHidden = !display
        layoutIfNeeded()
    }
}

// MARK: - UIContextMenuInteractionDelegate

extension MessagePhotoCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ -> UIMenu? in
            guard let self = self else { return nil }
            let shareItem = UIAction(title: AppStrings.Actions.share, image: UIImage(systemName: AppStrings.Icons.share)) { [weak self] _ in
                guard let self = self else { return }
                self.delegate?.didTapMenu(.share)
            }
            return UIMenu(children: [shareItem])
        }
    }
}


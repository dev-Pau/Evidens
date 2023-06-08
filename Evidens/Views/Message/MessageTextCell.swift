//
//  MessageTextCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 29/5/23.
//

import UIKit

class MessageTextCell: UICollectionViewCell {
    
    var viewModel: MessageViewModel? {
        didSet {
            configureWithMessage()
        }
    }
    
    var display: Bool = false
    
    weak var delegate: MessageCellDelegate?
    private var bubbleLeadingConstraint: NSLayoutConstraint!
    private var bubbleTrailingConstraint: NSLayoutConstraint!
    private var bubbleTopConstraint: NSLayoutConstraint!
    private var bubbleViewBottomAnchor: NSLayoutConstraint!
    
    private var timeLeadingConstriant: NSLayoutConstraint!
    private var timeTrailingConstraint: NSLayoutConstraint!

    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        label.backgroundColor = .clear
        return label
    }()
    
    private lazy var timestampLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14, weight: .regular)
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
    
    private let bubbleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        view.layer.masksToBounds = true
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 15
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let bubbleImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        return iv
    }()
    
    private lazy var errorButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration?.baseBackgroundColor = .systemRed
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.exclamation, withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.scalePreservingAspectRatio(targetSize: CGSize(width: 10, height: 15)).withRenderingMode(.alwaysOriginal).withTintColor(.white)
        button.configuration?.buttonSize = .mini
        button.configuration?.cornerStyle = .capsule
        return button
    }()
    
    /// Initializes a new instance of the view with the specified frame.
    ///
    /// - Parameters:
    ///   - frame: The frame rectangle for the view, measured in points.
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bubbleLeadingConstraint.isActive = false
        bubbleTrailingConstraint.isActive = false
        timeLeadingConstriant.isActive = false
        timeTrailingConstraint.isActive = false
        bubbleViewBottomAnchor.isActive = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if bubbleView.frame.width < bubbleView.frame.height {
            bubbleView.layer.cornerRadius = bubbleView.frame.height / 4
        } else {
            bubbleView.layer.cornerRadius = min(18, bubbleView.frame.height / 2)
        }
        
        guard display == true, let viewModel = viewModel, !viewModel.emoji else {
            bubbleView.layer.mask = nil
            bubbleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            return
        }
        
        bubbleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: bubbleView.bounds,
                                      byRoundingCorners: [.bottomRight],
                                      cornerRadii: CGSize(width: 5, height: 5)).cgPath
        bubbleView.layer.mask = maskLayer
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        
        addSubviews(timestampLabel, bubbleView, timeLabel, errorButton)
        bubbleView.addSubviews(messageLabel)
        
        let constant = viewModel.failed ? 35.0 : 10.0
        errorButton.isHidden = !viewModel.failed
        
        if viewModel.isSender {
            bubbleTrailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -constant)
            bubbleLeadingConstraint = bubbleView.widthAnchor.constraint(lessThanOrEqualToConstant: frame.width - 70)
            timeTrailingConstraint = timeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
            timeLeadingConstriant = bubbleLeadingConstraint
        } else {
            bubbleLeadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: constant)
            bubbleTrailingConstraint = bubbleView.widthAnchor.constraint(lessThanOrEqualToConstant: frame.width - 70)
            timeLeadingConstriant = timeLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 10)
            timeTrailingConstraint = bubbleTrailingConstraint
        }
        
        if viewModel.kind == . emoji{
            messageLabel.font = .systemFont(ofSize: viewModel.size, weight: .regular)
        } else {
            messageLabel.font = .systemFont(ofSize: 16, weight: .regular)
        }

        bubbleTopConstraint = bubbleView.topAnchor.constraint(equalTo: topAnchor)
        bubbleViewBottomAnchor = bubbleView.bottomAnchor.constraint(equalTo: bottomAnchor)
        
        NSLayoutConstraint.activate([
            timestampLabel.topAnchor.constraint(equalTo: topAnchor),
            timestampLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            timestampLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            bubbleView.topAnchor.constraint(equalTo: timestampLabel.bottomAnchor),
            bubbleTrailingConstraint,
            bubbleLeadingConstraint,
            bubbleViewBottomAnchor,
            // this in the top
            
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 10),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -10),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10),
        
            timeLeadingConstriant,
            timeTrailingConstraint,
            timeLabel.topAnchor.constraint(equalTo: bubbleView.bottomAnchor),

            errorButton.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
            errorButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            errorButton.heightAnchor.constraint(equalToConstant: 20),
            errorButton.widthAnchor.constraint(equalToConstant: 20)
        ])
        
        let contextMenu = UIContextMenuInteraction(delegate: self)
        bubbleView.addInteraction(contextMenu)
        
        let deleteAction = UIAction(title: AppStrings.Alerts.Title.deleteMessage, image: UIImage(systemName: AppStrings.Icons.trash, withConfiguration: UIImage.SymbolConfiguration(weight: .medium)), attributes: .destructive) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.didTapMenuOption(message: viewModel.message, .delete)
        }

        let sendAction = UIAction(title: AppStrings.Alerts.Title.resendMessage, image: UIImage(systemName: AppStrings.Icons.clockwiseArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.didTapMenuOption(message: viewModel.message, .resend)
        }
        
        errorButton.menu = UIMenu(children: [deleteAction, sendAction])
        errorButton.showsMenuAsPrimaryAction = true
    }
    
    private func configureWithMessage() {
        guard let viewModel = viewModel else { return }
        timeLabel.text = viewModel.time
        messageLabel.text = viewModel.text
        if viewModel.isSender {
            bubbleView.backgroundColor = viewModel.emoji ? .clear : primaryColor
            messageLabel.textColor = .white
        } else {
            bubbleView.backgroundColor = viewModel.emoji ? .clear : .systemGray3
            messageLabel.textColor = .label
        }
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
    
    func displayBezierPath(_ display: Bool) {
        self.display = display
    }
    
    func displayTime(_ display: Bool) {
        bubbleViewBottomAnchor.constant = display ? -13 : 0
        timeLabel.isHidden = !display
        layoutIfNeeded()
    }
    
    func highlight() {
        guard let viewModel = viewModel else { return }
        
        if viewModel.isSender {
            bubbleView.backgroundColor = primaryColor.withAlphaComponent(1.5)
            timeLabel.textAlignment = .right
        } else {
            bubbleView.backgroundColor = .secondaryLabel
            timeLabel.textAlignment = .left
        }
    }
    /*
    @objc func handleBubbleSwipe() {
        guard let panGestureRecognizer = panGestureRecognizer, let viewModel = viewModel else { return }
        let x = panGestureRecognizer.translation(in: bubbleView).x
        
        if viewModel.isSender {
            if x < 0 {
                if x > -50 {
                    bubbleTrailingConstraint.constant = x
                } else {
                    bubbleTrailingConstraint.constant = -50 + (x + 50) * 0.3
                }
            }
        } else {
            if x > 0 {
                if x < 50 {
                    bubbleLeadingConstraint.constant = x
                } else {
                    bubbleLeadingConstraint.constant = 50 + (x - 50) * 0.3
                }
            }
        }
        
        if panGestureRecognizer.state == .ended {
            let constant = viewModel.failed ? 35.0 : 10.0
            
            if viewModel.isSender {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.bubbleTrailingConstraint.constant = -constant
                    strongSelf.layoutIfNeeded()
                }
            } else {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.bubbleLeadingConstraint.constant = constant
                    strongSelf.layoutIfNeeded()
                }
            }
            
            panGestureRecognizer.isEnabled = false
        }
    }
     */
}

extension MessageTextCell: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ -> UIMenu? in
            guard let self = self else { return nil }
            let shareItem = UIAction(title: MessageMenu.copy.label, image: MessageMenu.copy.image) { [weak self] _ in
                guard let self = self else { return }
                UIPasteboard.general.string = self.timestampLabel.text
            }
            return UIMenu(children: [shareItem])
        }
    }
}


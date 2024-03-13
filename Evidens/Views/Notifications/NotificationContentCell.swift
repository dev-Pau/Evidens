//
//  NotificationContentCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/8/22.
//

import UIKit

class NotificationContentCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    weak var delegate: NotificationCellDelegate?
    
    var viewModel: NotificationViewModel? {
        didSet {
            configureNotification()
        }
    }
    
    private var user: User?
    
    private lazy var profileImageView = ProfileImageView(frame: .zero)
    
    private let contentTextView: UITextView = {
        let tv = UITextView()
        tv.textContainer.maximumNumberOfLines = 4
        tv.textContainerInset = .zero
        tv.contentInset = .zero
        tv.textContainer.lineBreakMode = .byTruncatingTail
        tv.backgroundColor = .clear
        tv.isSelectable = false
        tv.linkTextAttributes = [.foregroundColor: UIColor.label]
        tv.isUserInteractionEnabled = true
        tv.isEditable = false
        tv.delaysContentTouches = false
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.contentInset = .zero
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = .zero
        return tv
    }()
    
    private lazy var unreadImage: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = primaryColor
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private var dotButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        
        let buttonSize: CGFloat = UIDevice.isPad ? 25 : 20
        
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.ellipsis)?.scalePreservingAspectRatio(targetSize: CGSize(width: buttonSize, height: buttonSize)).withRenderingMode(.alwaysOriginal).withTintColor(separatorColor)
        button.adjustsImageSizeForAccessibilityContentSizeCategory = false
        button.configuration?.buttonSize = .mini
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        return button
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .medium)
        label.textColor = primaryGray
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleAction))
        addGestureRecognizer(tap)
        
        backgroundColor = .systemBackground
        
        let imageSize: CGFloat = UIDevice.isPad ? 63 : 53
        let buttonSize: CGFloat = UIDevice.isPad ? 35 : 30
        
        addSubviews(unreadImage, profileImageView, dotButton, contentTextView, timeLabel, separatorView)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 17),
            profileImageView.widthAnchor.constraint(equalToConstant: imageSize),
            profileImageView.heightAnchor.constraint(equalToConstant: imageSize),
            
            unreadImage.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            unreadImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            unreadImage.heightAnchor.constraint(equalToConstant: 7),
            unreadImage.widthAnchor.constraint(equalToConstant: 7),
            
            dotButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            dotButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            dotButton.heightAnchor.constraint(equalToConstant: buttonSize),
            dotButton.widthAnchor.constraint(equalToConstant: buttonSize),
            
            contentTextView.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            contentTextView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            contentTextView.trailingAnchor.constraint(equalTo: dotButton.leadingAnchor, constant: -10),

            timeLabel.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 5),
            timeLabel.leadingAnchor.constraint(equalTo: contentTextView.leadingAnchor),
            timeLabel.bottomAnchor.constraint(greaterThanOrEqualTo: profileImageView.bottomAnchor),
            timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        profileImageView.layer.cornerRadius = 8
        profileImageView.isUserInteractionEnabled = true
        unreadImage.layer.cornerRadius = 7 / 2
        contentTextView.delegate = self
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTextViewTap(_:)))
        contentTextView.addGestureRecognizer(gestureRecognizer)
        
        backgroundColor = .systemBackground
    }
    
    func addMenuItems() -> UIMenu? {
        guard let viewModel = viewModel else { return nil }
        let menuItem = UIMenu(title: "", subtitle: "", image: nil, identifier: nil, options: .displayInline, children: [
            UIAction(title: AppStrings.Alerts.Title.deleteNotification, image: UIImage(systemName: AppStrings.Icons.trash), handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.cell(strongSelf, didPressThreeDotsFor: viewModel.notification, option: .delete)
            })
        ])
        
        dotButton.showsMenuAsPrimaryAction = true
        return menuItem
    }
    
    private func configureNotification() {
        guard let viewModel = viewModel else { return }
        dotButton.menu = addMenuItems()
        
        let boldFont = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .semibold)
        let font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)

        let attributedText = NSMutableAttributedString(string: viewModel.name, attributes: [.font: boldFont, .foregroundColor: UIColor.label, .link: NSAttributedString.Key.link])
        
        attributedText.append(NSAttributedString(string: viewModel.summary, attributes: [.font: font, .foregroundColor: UIColor.label]))
        
        attributedText.append(NSAttributedString(string: viewModel.message + " ", attributes: [.font: font, .foregroundColor: UIColor.label]))
       
        attributedText.append(NSAttributedString(string: viewModel.content.trimmingCharacters(in: .newlines), attributes: [.font: font, .foregroundColor: primaryGray]))
        
        timeLabel.text = viewModel.time
        
        unreadImage.isHidden = viewModel.isRead
        backgroundColor = viewModel.isRead ? .systemBackground : primaryColor.withAlphaComponent(0.1)
        
        contentTextView.attributedText = attributedText

        if let image = viewModel.image() {
            profileImageView.sd_setImage(with: image, placeholderImage: UIImage(named: AppStrings.Assets.placeholderContent)!)
        } else {
            profileImageView.image = UIImage(named: AppStrings.Assets.placeholderContent)!
        }
        
        layoutIfNeeded()
    }
   
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Actions
    
    @objc func handleTextViewTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let viewModel = viewModel else { return }
        let location = gestureRecognizer.location(in: contentTextView)
        let position = contentTextView.closestPosition(to: location)!

        if let range = contentTextView.tokenizer.rangeEnclosingPosition(position, with: .character, inDirection: .layout(.left)) {
            let startIndex = contentTextView.offset(from: contentTextView.beginningOfDocument, to: range.start)
           
            let attributes = contentTextView.attributedText.attributes(at: startIndex, effectiveRange: nil)
            
            if attributes.keys.contains(.link) {
                delegate?.cell(self, wantsToViewProfile: viewModel.notification.uid)
            } else {
                delegate?.cell(self, wantsToSeeContentFor: viewModel.notification)
            }
        }
    }
   
    @objc func handleAction() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, wantsToSeeContentFor: viewModel.notification)
    }
}


extension NotificationContentCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return false
    }
}
    

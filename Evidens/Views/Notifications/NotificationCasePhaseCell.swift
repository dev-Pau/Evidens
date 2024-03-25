//
//  NotificationCasePhaseCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 5/1/24.
//

import UIKit

class NotificationCasePhaseCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    weak var delegate: NotificationCellDelegate?
    
    var viewModel: NotificationViewModel? {
        didSet {
            configureNotification()
        }
    }
    
    private var user: User?
    
    private lazy var phaseImage: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .center
        let imageSize: CGFloat = UIDevice.isPad ? 47 : 37
        iv.image = UIImage(systemName: AppStrings.Icons.fireworks)?.withRenderingMode(.alwaysOriginal).withTintColor(.white).scalePreservingAspectRatio(targetSize: CGSize(width: imageSize, height: imageSize))
        iv.backgroundColor = K.Colors.primaryColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 8
        return iv
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.numberOfLines = 4
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var unreadImage: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = K.Colors.primaryColor
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private var dotButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        
        let buttonSize: CGFloat = UIDevice.isPad ? 25 : 20
        
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.ellipsis)?.scalePreservingAspectRatio(targetSize: CGSize(width: buttonSize, height: buttonSize)).withRenderingMode(.alwaysOriginal).withTintColor(K.Colors.separatorColor)
        button.adjustsImageSizeForAccessibilityContentSizeCategory = false
        button.configuration?.buttonSize = .mini
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        return button
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .medium)
        label.textColor = K.Colors.primaryGray
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = K.Colors.separatorColor
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
        
        addSubviews(unreadImage, phaseImage, dotButton, textLabel, timeLabel, separatorView)
        
        NSLayoutConstraint.activate([
            phaseImage.topAnchor.constraint(equalTo: topAnchor, constant: K.Paddings.Content.verticalPadding),
            phaseImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            phaseImage.widthAnchor.constraint(equalToConstant: imageSize),
            phaseImage.heightAnchor.constraint(equalToConstant: imageSize),
            
            unreadImage.centerYAnchor.constraint(equalTo: phaseImage.centerYAnchor),
            unreadImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            unreadImage.heightAnchor.constraint(equalToConstant: 7),
            unreadImage.widthAnchor.constraint(equalToConstant: 7),
            
            dotButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            dotButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -K.Paddings.Content.horizontalPadding),
            dotButton.heightAnchor.constraint(equalToConstant: buttonSize),
            dotButton.widthAnchor.constraint(equalToConstant: buttonSize),
            
            textLabel.topAnchor.constraint(equalTo: phaseImage.topAnchor),
            textLabel.leadingAnchor.constraint(equalTo: phaseImage.trailingAnchor, constant: 10),
            textLabel.trailingAnchor.constraint(equalTo: dotButton.leadingAnchor, constant: -10),

            timeLabel.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 5),
            timeLabel.leadingAnchor.constraint(equalTo: textLabel.leadingAnchor),
            timeLabel.bottomAnchor.constraint(greaterThanOrEqualTo: phaseImage.bottomAnchor),
            timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -K.Paddings.Content.verticalPadding),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        unreadImage.layer.cornerRadius = 7 / 2
        
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
        
        let _ = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .semibold)
        let font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        
        let attributedText = NSMutableAttributedString(string: viewModel.summary, attributes: [.font: font])
        
        attributedText.append(NSAttributedString(string: viewModel.content.trimmingCharacters(in: .newlines), attributes: [.font: font, .foregroundColor: K.Colors.primaryGray]))

        timeLabel.text = viewModel.time
        
        unreadImage.isHidden = viewModel.isRead
        backgroundColor = viewModel.isRead ? .systemBackground : K.Colors.primaryColor.withAlphaComponent(0.1)
        
        textLabel.attributedText = attributedText
        
        layoutIfNeeded()
    }
   
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Actions
   
    @objc func handleAction() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, wantsToSeeContentFor: viewModel.notification)
    }
    
    @objc func didTapProfile() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, wantsToViewProfile: viewModel.notification.uid)
    }
}

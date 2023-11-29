//
//  ConnectUserCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 28/2/23.
//

import UIKit

protocol ConnectUserCellDelegate: AnyObject {
    func didConnect(_ cell: UICollectionViewCell, connection: UserConnection)
}

class ConnectUserCell: UICollectionViewCell {
    
    weak var connectionDelegate: ConnectUserCellDelegate?
    
    var viewModel: ConnectViewModel? {
        didSet {
            configureUser()
        }
    }
    
    private lazy var profileImageView = ProfileImageView(frame: .zero)
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .callout)
        let blackFontDescriptor = fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.traits: [
                UIFontDescriptor.TraitKey.weight: UIFont.Weight.bold.rawValue
            ]
        ])
        
        label.font = UIFont(descriptor: blackFontDescriptor, size: 0)
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = .label
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let discipline: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var connectButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintAdjustmentMode = .normal
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        
        button.configuration?.baseBackgroundColor = primaryColor
        
        button.configuration?.baseForegroundColor = .systemBackground
        button.configuration?.cornerStyle = .capsule
        button.configuration?.background.strokeWidth = 1
        
        button.addTarget(self, action: #selector(handleConnect), for: .touchUpInside)
        
        button.isUserInteractionEnabled = true
        
        return button
    }()
    
    private let separator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubviews(connectButton, profileImageView, nameLabel, discipline, separator)
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            profileImageView.heightAnchor.constraint(equalToConstant: 43),
            profileImageView.widthAnchor.constraint(equalToConstant: 43),
            
            connectButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            connectButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            connectButton.heightAnchor.constraint(equalToConstant: 35),
            connectButton.widthAnchor.constraint(equalToConstant: 110),
            
            nameLabel.bottomAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: connectButton.leadingAnchor, constant: -5),
            
            discipline.topAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            discipline.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            discipline.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -10),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
            separator.heightAnchor.constraint(equalToConstant: 0.4)
        ])
        
        profileImageView.layer.cornerRadius = 43 / 2
    }
    
    func configureUser() {
        guard let viewModel = viewModel else { return }
        
        if let imageUrl = viewModel.profileUrl, imageUrl != "" {
            profileImageView.sd_setImage(with: URL(string: imageUrl))
        }
        
        nameLabel.text = viewModel.name
        discipline.text = viewModel.details
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 14, weight: .bold)
        connectButton.configuration?.attributedTitle = AttributedString(viewModel.title, attributes: container)

        connectButton.configuration?.baseBackgroundColor = viewModel.color
        connectButton.configuration?.baseForegroundColor = viewModel.foregroundColor
        connectButton.configuration?.background.strokeColor = viewModel.strokeColor
        connectButton.configuration?.background.strokeWidth = viewModel.strokeWidth
        connectButton.isUserInteractionEnabled = !viewModel.user.isCurrentUser
        connectButton.isHidden = viewModel.user.isCurrentUser
    }
    
    func enableButton() {
        connectButton.isUserInteractionEnabled = true
    }
    
    func disableButton() {
        connectButton.isUserInteractionEnabled = false
    }
    
    @objc func handleConnect() {
        guard let viewModel = viewModel, let connection = viewModel.connection else { return }
        guard let phase = UserDefaults.getPhase(), phase == .verified else {
            ContentManager.shared.permissionAlert(kind: .connections)
            return
        }
        connectionDelegate?.didConnect(self, connection: connection)
    }
}

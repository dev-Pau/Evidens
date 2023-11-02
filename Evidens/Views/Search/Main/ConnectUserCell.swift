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
        label.font = .systemFont(ofSize: 16, weight: .bold)
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
        label.font = .systemFont(ofSize: 15, weight: .regular)
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
            profileImageView.heightAnchor.constraint(equalToConstant: 53),
            profileImageView.widthAnchor.constraint(equalToConstant: 53),
            
            connectButton.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 7),
            connectButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            connectButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -7),
            connectButton.widthAnchor.constraint(equalToConstant: 110),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: connectButton.leadingAnchor, constant: -10),
            
            discipline.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            discipline.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            discipline.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -10),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
            separator.heightAnchor.constraint(equalToConstant: 0.4)
        ])
        
        profileImageView.layer.cornerRadius = 53 / 2
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
        connectionDelegate?.didConnect(self, connection: connection)
    }
}

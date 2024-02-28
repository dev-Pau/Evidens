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
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .semibold)
       
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = .label
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.textColor = primaryGray
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private let discipline: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var connectButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintAdjustmentMode = .normal
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        
        button.configuration?.baseBackgroundColor = primaryColor
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0)
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
        let size: CGFloat = UIDevice.isPad ? 150 : 115
        let imageSize: CGFloat = UIDevice.isPad ? 53 : 43
        
        let stackView = UIStackView(arrangedSubviews: [nameLabel, usernameLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        
        addSubviews(connectButton, profileImageView, stackView, discipline, separator)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            profileImageView.heightAnchor.constraint(equalToConstant: imageSize),
            profileImageView.widthAnchor.constraint(equalToConstant: imageSize),
            
            connectButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            connectButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            connectButton.widthAnchor.constraint(equalToConstant: size),
            
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: connectButton.leadingAnchor, constant: -5),
            
            discipline.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 5),
            discipline.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            discipline.trailingAnchor.constraint(equalTo: connectButton.trailingAnchor),
            discipline.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -10),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
            separator.heightAnchor.constraint(equalToConstant: 0.4)
        ])
        
        profileImageView.layer.cornerRadius = imageSize / 2
    }
    
    func configureUser() {
        guard let viewModel = viewModel else { return }
        let imageSize: CGFloat = UIDevice.isPad ? 53 : 43
        profileImageView.addImage(forUser: viewModel.user, size: imageSize)
        nameLabel.text = viewModel.name
        discipline.text = viewModel.details
        usernameLabel.text = viewModel.username
        
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 14, scaleStyle: .body, weight: .bold, scales: false)
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

//
//  ProfileNameView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/1/24.
//

import UIKit

protocol ProfileNameViewDelegate: AnyObject {
    func didTapNetwork()
    func didTapProfileImage()
}

class ProfileNameView: UIView {
    
    weak var delegate: ProfileNameViewDelegate?
    
    private let padding: CGFloat = 10
    
    private let bannerImage: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = guidelineColor
        iv.layer.borderColor = separatorColor.cgColor
        iv.isUserInteractionEnabled = false
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let name: UILabel = {
        let label = UILabel()
        let bigFont: CGFloat = UIDevice.isPad ? 25 : 23
        label.font = UIFont.addFont(size: bigFont, scaleStyle: .largeTitle, weight: .bold, scales: false)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.numberOfLines = 2
        label.textColor = .label
        return label
    }()
    
    private lazy var profileImage: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .quaternarySystemFill
        iv.layer.borderWidth = 1
        iv.layer.borderColor = separatorColor.cgColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageTap)))
        iv.image = UIImage(named: AppStrings.Assets.profile)
        return iv
    }()
    
    private let discipline: UILabel = {
        let label = UILabel()
        let smallFont: CGFloat = UIDevice.isPad ? 16 : 13
        label.font = UIFont.addFont(size: smallFont, scaleStyle: .largeTitle, weight: .regular, scales: false)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.isUserInteractionEnabled = false
        label.textColor = primaryGray
        return label
    }()
    
    private lazy var connections: UILabel = {
        let label = UILabel()
        label.textColor = primaryGray
        let smallFont: CGFloat = UIDevice.isPad ? 16 : 13
        label.font = UIFont.addFont(size: smallFont, scaleStyle: .largeTitle, weight: .regular, scales: false)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowNetwork)))
        label.isUserInteractionEnabled = true
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
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
        
        let bannerHeight = (UIScreen.main.bounds.width - 20.0) / bannerAR
        let imageHeight = UIDevice.isPad ? 120.0 : 75.0
    
        var disciplineStackView = UIStackView(arrangedSubviews: [discipline, connections])
        disciplineStackView.translatesAutoresizingMaskIntoConstraints = false
        disciplineStackView.axis = .vertical
        disciplineStackView.spacing = 0
        
        var nameStackView = UIStackView(arrangedSubviews: [name, disciplineStackView])
        nameStackView.translatesAutoresizingMaskIntoConstraints = false
        nameStackView.axis = .vertical
        nameStackView.spacing = 5
        
        addSubviews(bannerImage, profileImage, nameStackView)
        
        NSLayoutConstraint.activate([
            bannerImage.topAnchor.constraint(equalTo: topAnchor),
            bannerImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            bannerImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            bannerImage.heightAnchor.constraint(equalToConstant: bannerHeight),
            
            profileImage.topAnchor.constraint(equalTo: bannerImage.bottomAnchor, constant: 2 * padding + padding / 2),
            profileImage.leadingAnchor.constraint(equalTo: bannerImage.leadingAnchor),
            profileImage.widthAnchor.constraint(equalToConstant: imageHeight),
            profileImage.heightAnchor.constraint(equalToConstant: imageHeight),
            profileImage.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            nameStackView.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            nameStackView.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: UIDevice.isPad ? 20 : 10),
            nameStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
        ])
        
        bannerImage.layer.cornerRadius = 12
        profileImage.layer.cornerRadius = imageHeight / 2
    }
    
    func set(viewModel: UserProfileViewModel) {
        name.text = viewModel.user.name()
        discipline.text = viewModel.user.details()
        
        if let url = viewModel.user.profileUrl, url != "" {
            profileImage.sd_setImage(with: URL(string: url))
            profileImage.layer.borderWidth = 1
        } else {
            profileImage.layer.borderWidth = 0.4
            profileImage.image = UIImage(named: AppStrings.Assets.profile)
        }
        
        if let banner = viewModel.user.bannerUrl, banner != "" {
            bannerImage.sd_setImage(with: URL(string: banner))
            bannerImage.layer.borderWidth = 1
        } else {
            bannerImage.layer.borderWidth = 0.4
            bannerImage.image = nil
        }
    }
    
    func configure(viewModel: ProfileHeaderViewModel) {
        connections.attributedText = viewModel.connectionsText
    }
    
    @objc func handleShowNetwork() {
        delegate?.didTapNetwork()
    }
    
    @objc func handleImageTap() {
        delegate?.didTapProfileImage()
    }
}


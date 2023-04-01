//
//  UserProfilePatentsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/8/22.
//

import UIKit

private let userCellReuseIdentifier = "UserCellReuseIdentifier"

protocol UserProfilePatentCellDelegate: AnyObject {
    func didTapEditPatent(_ cell: UICollectionViewCell, patentTitle: String, patentNumber: String, patentDescription: String)
    func didTapShowContributors(users: [User])
}

class UserProfilePatentCell: UICollectionViewCell {
    
    weak var delegate: UserProfilePatentCellDelegate?
    
    var users: [User]? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private let patentTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .label
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let patentNumberLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = .label
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var buttonImage: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        button.configuration?.buttonSize = .mini
        button.isHidden = true
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleEditPatent), for: .touchUpInside)
        return button
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    
    var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .quaternarySystemFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        collectionView.register(GroupUserCell.self, forCellWithReuseIdentifier: userCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        backgroundColor = .systemBackground
        addSubviews(patentTitleLabel, patentNumberLabel, separatorView, buttonImage, collectionView)
        
        NSLayoutConstraint.activate([
            patentTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            patentTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            patentTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            patentNumberLabel.topAnchor.constraint(equalTo: patentTitleLabel.bottomAnchor, constant: 5),
            patentNumberLabel.leadingAnchor.constraint(equalTo: patentTitleLabel.leadingAnchor),
            patentNumberLabel.trailingAnchor.constraint(equalTo: patentTitleLabel.trailingAnchor),
            patentNumberLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -52),
            
            collectionView.topAnchor.constraint(equalTo: patentNumberLabel.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: patentNumberLabel.leadingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 32),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            buttonImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            buttonImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
    
    func set(patentInfo: [String: Any]) {
        patentTitleLabel.text = patentInfo["title"] as? String
        patentNumberLabel.text = patentInfo["number"] as? String
        
        if let contributorsUid = patentInfo["contributors"] as? [String] {
            UserService.fetchUsers(withUids: contributorsUid) { users in
                self.users = users
                self.collectionView.reloadData()
            }
        }
    }
    
    @objc func handleEditPatent() {
        guard let title = patentTitleLabel.text, let number = patentNumberLabel.text else { return }
        delegate?.didTapEditPatent(self, patentTitle: title, patentNumber: number, patentDescription: description)
    }
}

extension UserProfilePatentCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users?.count ?? 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userCellReuseIdentifier, for: indexPath) as! GroupUserCell
        cell.set(user: users?[indexPath.row] ?? User(dictionary: [:]))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 32, height: 32)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return -10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let users = users, users.count > 1 else { return }
        delegate?.didTapShowContributors(users: users)
    }
}


//
//  recentCollectionCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/5/22.
//

import UIKit


private let identifier = "collectionCell"

protocol RecentUserCellDelegate: AnyObject {
    func didTapProfileFor(_ user: User)
}

class RecentUserCell: UITableViewCell {
    
    //MARK: - Properties
    private var users = [User]()
    
    weak var delegate: RecentUserCellDelegate?
        
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isUserInteractionEnabled = true
        collectionView.register(UserCollectionViewCell.self, forCellWithReuseIdentifier: identifier)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    lazy var noRecentUsersLabel: UILabel = {
        let label = UILabel()
        label.text = "Your recent user searches will appear here"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = grayColor
        //label.isHidden = true
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        fetchUsers()
        contentView.addSubviews(collectionView, noRecentUsersLabel)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            noRecentUsersLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            noRecentUsersLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            noRecentUsersLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            noRecentUsersLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
        collectionView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - API
    func fetchUsers() {
        DatabaseManager.shared.fetchRecentUserSearches { result in
            switch result {
            case .success(let uids):
                self.collectionView.isHidden = uids.isEmpty ? true : false
                self.noRecentUsersLabel.isHidden = uids.isEmpty ? false : true
                
                UserService.fetchUsers(withUids: uids) { users in
                    self.users = users
                    self.collectionView.reloadData()
                }
            case .failure(_):
                print("Couldn't fetch recent useres")
            }
        }
    }
}

//MARK: - UICollectionViewDataSource

extension RecentUserCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! UserCollectionViewCell
        //cell.delegate = self
        cell.viewModel = UserRecentCellViewModel(user: users[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
            let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                return UIMenu(title: "", subtitle: nil, image: nil, identifier: nil, options: .displayInline, children: [
                    UIAction(title: "Report Post", image: UIImage(systemName: "flag"), handler: { (_) in
                        print("Report post pressed")
                    })
                ])
            }
            return config
        }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension RecentUserCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected item at \(indexPath.row)")
        delegate?.didTapProfileFor(users[indexPath.row])
    }
}

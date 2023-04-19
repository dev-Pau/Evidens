//
//  GroupInviteViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 31/1/23.
//

import UIKit
import JGProgressHUD

private let searchBarHeaderReuseIdentifier = "SearchBarHeaderReuseIdentifier"
private let headerLoadingReuseIdentifier = "HeaderLoadingReuseIdentifier"
private let previewSelectedReuseIdentifier = "PreviewSelectedReuseIdentifier"
private let groupInviteReuseIdentifier = "GroupInviteReuseIdentifier"

class GroupInviteViewController: UIViewController {
    
    private var group: Group
    private var usersSelected = [User]()
    private var users = [User]()
    
    private var loaded: Bool = false
    
    private var collectionView: UICollectionView!
    
    private let activityIndicator = JGProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        fetchUsers()
    }
    
    init(group: Group) {
        self.group = group
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = "Invite Network"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(handleInviteMembers))
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.allowsMultipleSelection = true
        collectionView.keyboardDismissMode = .interactive
        view.addSubview(collectionView)
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: headerLoadingReuseIdentifier)
        collectionView.register(GroupSearchBarHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: searchBarHeaderReuseIdentifier)
        collectionView.register(MEPreviewSelectedCell.self, forCellWithReuseIdentifier: previewSelectedReuseIdentifier)
        collectionView.register(GroupInviteCell.self, forCellWithReuseIdentifier: groupInviteReuseIdentifier)
        //collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "kek")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            
            if sectionNumber == 0 {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .estimated(100), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .estimated(100), heightDimension: .absolute(30)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10)
                
                return section
                
            } else if sectionNumber == 1 {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .estimated(200), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .estimated(200), heightDimension: .absolute(30)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40)), elementKind: ElementKind.sectionHeader, alignment: .top)
                header.pinToVisibleBounds = true
                section.boundarySupplementaryItems = [header]
                return section
                
            } else {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(65)))
                item.contentInsets.top = 10
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(65)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                //section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0)
                return section
            }
        }
        
        return layout
    }
    
    private func fetchUsers() {
    #warning("modiifcar la funció perquè no apareguin els users que ja estàn al grup...")
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        UserService.fetchFollowing(forUid: uid, lastSnapshot: nil) { snapshot in
            guard !snapshot.isEmpty else {
                self.loaded = true
                self.collectionView.reloadData()
                return
            }
            //self.followingLastSnapshot = snapshot.documents.last
            let uids = snapshot.documents.map({ $0.documentID })
            UserService.fetchUsers(withUids: uids) { users in
                self.loaded = true
                self.users = users
                self.collectionView.reloadData()
            }
        }
    }
     
    @objc func handleInviteMembers() {
        let uids = usersSelected.map { $0.uid! }
        activityIndicator.show(in: view)
        DatabaseManager.shared.inviteUsersToGroup(groupId: group.groupId, uids: uids) { invited in
            self.activityIndicator.dismiss(animated: true)
            
            let popUp = METopPopupView(title: uids.count > 1 ? "Invitations have been sent successfully" : "Invitation has been sent successfully", image: "checkmark.circle.fill", popUpType: .regular)
            popUp.showTopPopup(inView: self.view)
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension GroupInviteViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            return loaded ? usersSelected.isEmpty ? 1 : usersSelected.count : 0
        } else if section == 1 {
            return 0
        } else {
            return loaded ? users.count : 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: previewSelectedReuseIdentifier, for: indexPath) as! MEPreviewSelectedCell
            if usersSelected.isEmpty {
                cell.configureWithDefaultValues()
                return cell
            } else {
                cell.configure(with: usersSelected[indexPath.row].firstName! + " " + usersSelected[indexPath.row].lastName!)
                return cell
            }

        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupInviteReuseIdentifier, for: indexPath) as! GroupInviteCell
            cell.set(user: users[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if !loaded {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerLoadingReuseIdentifier, for: indexPath) as! MELoadingHeader
            return header
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: searchBarHeaderReuseIdentifier, for: indexPath) as!
            GroupSearchBarHeader
            #warning("need to implement search bar header")
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return usersSelected.isEmpty ? false : true
        } else if indexPath.section == 2 {
            return usersSelected.count > 4 ? false : true
        } else {
            return false
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let userIndex = users.firstIndex { user in
                if user.uid == usersSelected[indexPath.row].uid {
                    return true
                }
                return false
            }
            
            if let userIndex = userIndex {
                usersSelected.remove(at: indexPath.row)
                collectionView.reloadSections(IndexSet(integer: 0))
                collectionView.deselectItem(at: IndexPath(item: userIndex, section: 2), animated: true)
                navigationItem.rightBarButtonItem?.isEnabled = usersSelected.isEmpty ? false : true
            }
          
        } else {
            usersSelected.insert(users[indexPath.row], at: 0)
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
            collectionView.reloadSections(IndexSet(integer: 0))
            navigationItem.rightBarButtonItem?.isEnabled = usersSelected.isEmpty ? false : true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let userIndex = usersSelected.firstIndex { user in
            if user.uid == users[indexPath.row].uid {
                return true
            }
            return false
        }
        
        if let userIndex = userIndex {
            collectionView.deselectItem(at: indexPath, animated: true)
            usersSelected.remove(at: userIndex)
            collectionView.reloadSections(IndexSet(integer: 0))
            navigationItem.rightBarButtonItem?.isEnabled = usersSelected.isEmpty ? false : true
        }
    }
}

//
//  GroupsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/11/22.
//

import UIKit

private let groupSkeletonCellReuseIdentifier = "GroupSkeletonCellReuseIdentifier"
private let exploreHeaderCellReuseIdentifier = "ExploreHeaderReuseIdentifier"
private let groupManagerCellReuseIdentifier = "GroupManagerCellReuseIdentifier"
private let groupContentCellReuseIdentifier = "ExploreCellReuseIdentifier"


class GroupsViewController: UIViewController {

    private var user: User
    
    private var group = Group(groupId: "", dictionary: [:])
    private var groupUsers = [User]()
    
    private var groupLoaded: Bool = false
    
    private var groupMenuLauncher = GroupMenuLauncher()
    
    private let groupsListCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 90)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        fetchUserGroups()

        view.backgroundColor = .white
        configureCollectionView()
        configureUI()
        groupMenuLauncher.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !groupLoaded { groupsListCollectionView.reloadData() }
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Groups"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(didTapCreateGroup))
        navigationItem.rightBarButtonItem?.tintColor = grayColor
    }
    
    
    private func configureCollectionView() {
        groupsListCollectionView.backgroundColor = lightColor
        groupsListCollectionView.delegate = self
        groupsListCollectionView.dataSource = self
        groupsListCollectionView.register(GroupSkeletonCell.self, forCellWithReuseIdentifier: groupSkeletonCellReuseIdentifier)
        groupsListCollectionView.register(DiscoverGroupCell.self, forCellWithReuseIdentifier: exploreHeaderCellReuseIdentifier)
        groupsListCollectionView.register(GroupManagerCell.self, forCellWithReuseIdentifier: groupManagerCellReuseIdentifier)
        groupsListCollectionView.register(ExploreGroupsCell.self, forCellWithReuseIdentifier: groupContentCellReuseIdentifier)
        // el group manager header té tots els grups que forma part l'usuari i els pot seleccionar com linsta, que apretes i et surt un menú a baix dels grups que forma part.
        // primer surtin els grups que
        // la part de explorar grups, que surti el nom
        // llavors es van afegint la resta, de posts publicacions o opinions
    }
    
    private func configureUI() {
        view.addSubview(groupsListCollectionView)
        groupsListCollectionView.frame = view.bounds
    }
    
    private func fetchUserGroups() {
        // Fetch last group selected by the user and saved in UserDefaults
        GroupService.fetchUserGroups { groups in
            self.group = groups.first!
            self.groupLoaded = true
            self.groupsListCollectionView.reloadData()
            self.didSelectGroup(group: self.group)
        }
    }
    
    @objc func didTapCreateGroup() {
        let controller = CreateGroupViewController()
        
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        
        present(nav, animated: true)
    }
}

extension GroupsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // posar-ho en funció de la secció
        if section == 0 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        if section == 1 { return 1 }
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: exploreHeaderCellReuseIdentifier, for: indexPath) as! DiscoverGroupCell
            cell.delegate = self
            return cell
        } else if indexPath.section == 1 {
            if !groupLoaded {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupSkeletonCellReuseIdentifier, for: indexPath) as! GroupSkeletonCell
                return cell
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupManagerCellReuseIdentifier, for: indexPath) as! GroupManagerCell
            cell.delegate = self
            cell.viewModel = GroupViewModel(group: group)
            cell.users = groupUsers
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupContentCellReuseIdentifier, for: indexPath) as! ExploreGroupsCell
        return cell
    }
}

extension GroupsViewController: DiscoverGroupCellDelegate {
    
    func didTapDiscover() {
        let controller = DiscoverGroupsViewController()
        let backItem = UIBarButtonItem()
        backItem.tintColor = .black
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension GroupsViewController: GroupManagerCellDelegate {
    func didTapShowMembers(members: String) {
        let controller = GroupMembersViewController(members: members, group: group)
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .black
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func didTapBrosweGroups() {
        let controller = GroupBrowserViewController()
        controller.delegate = self
        
        let nav = UINavigationController(rootViewController: controller)
        
        if let presentationController = nav.presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium()]
        }
        present(nav, animated: true)
    }
    
    func didTapShowMenu() {
        groupMenuLauncher.showGroupSettings(in: view)
    }
}

extension GroupsViewController: GroupBrowserViewControllerDelegate {
    func didTapDiscoverGroup() {
        let controller = DiscoverGroupsViewController()
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .black
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func didTapGroupCreate() {
        let controller = CreateGroupViewController()
        
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        
        present(nav, animated: true)
    }
    
    func didSelectGroup(group: Group) {
        self.group = group
        DatabaseManager.shared.fetchFirstGroupUsers(forGroupId: group.groupId) { uids in
            UserService.fetchUsers(withUids: uids) { users in
                self.groupUsers = users
                self.groupsListCollectionView.reloadItems(at: [IndexPath(row: 0, section: 1)])
            }
        }
    }
}

extension GroupsViewController: GroupMenuLauncherDelegate {
    func didTapBrowseGroups() {
        let controller = GroupBrowserViewController()
        controller.delegate = self
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .black
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func didTapDiscoverGroups() {
        let controller = DiscoverGroupsViewController()
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .black
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func didTapVisitGroup() {
        let controller = GroupPageViewController(group: group, isMember: true)
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .black
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem

        navigationController?.pushViewController(controller, animated: true)
    }
}

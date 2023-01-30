//
//  GroupMembershipViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/1/23.
//

import UIKit

private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let emptyGroupMembersCellReuseIdentifier = "EmptyGroupMembersCellReuseIdentifier"
private let searchHeaderReuseIdentifier = "SearchHeaderReuseIdentifier"

private let groupMemberUserCellReuseIdentifier = "GroupMemberUserCellReuseIdentifier"
private let pendingUserCellReuseIdentifier = "PendingUserCellReuseIdentifier"

class GroupMembershipViewController: UIViewController {
    
    private var group: Group
    
    weak var delegate: GroupBrowserViewControllerDelegate?
    
    weak var scrollDelegate: CollectionViewDidScrollDelegate?
    
    private let userMemberType: Group.MemberType
    
    private let memberUsers = [User]()
    private lazy var memberRequests = [User]()
    private lazy var memberInvited = [User]()
    private lazy var memberBlocked = [User]()
    
    private lazy var browserSegmentedButtonsView: CustomSegmentedButtonsView = {
        let segmentedButtonsView = CustomSegmentedButtonsView()
        segmentedButtonsView.setLabelsTitles(titles: Group.GroupMembershipManagement.allCases.map( {$0.rawValue} ))
        segmentedButtonsView.translatesAutoresizingMaskIntoConstraints = false
        segmentedButtonsView.backgroundColor = .systemBackground
        return segmentedButtonsView
    }()
    
    private var membersLoaded: Bool = false
    private var requestsLoaded: Bool = false
    private var invitedLoaded: Bool = false
    private var blockedLoaded: Bool = false
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .quaternarySystemFill
        return view
    }()
    
    private let membersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private let requestsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private let invitedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private let blockedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    
    
    init(group: Group, userMemberType: Group.MemberType) {
        self.group = group
        self.userMemberType = userMemberType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureCollectionView()
        view.backgroundColor = .systemBackground
        browserSegmentedButtonsView.segmentedControlDelegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        membersCollectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: scrollView.frame.height)
        requestsCollectionView.frame = CGRect(x: view.frame.width, y: 0, width: view.frame.width, height: scrollView.frame.height)
        invitedCollectionView.frame = CGRect(x: view.frame.width * 2, y: 0, width: view.frame.width, height: scrollView.frame.height)
        blockedCollectionView.frame = CGRect(x: view.frame.width * 3, y: 0, width: view.frame.width, height: scrollView.frame.height)
    }
    
    private func configureNavigationBar() {
        title = "Manage membership"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Admins", style: .done, target: self, action: #selector(handleAdminsTap))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
    }
    
    
    
    private func configureCollectionView() {
        membersCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        membersCollectionView.register(GroupSearchBarHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier)
        membersCollectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyGroupMembersCellReuseIdentifier)
        membersCollectionView.register(GroupMemberUserCell.self, forCellWithReuseIdentifier: groupMemberUserCellReuseIdentifier)
        
        requestsCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        requestsCollectionView.register(GroupSearchBarHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier)
        requestsCollectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyGroupMembersCellReuseIdentifier)
        requestsCollectionView.register(GroupUserRequestCell.self, forCellWithReuseIdentifier: pendingUserCellReuseIdentifier)
        
        invitedCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        invitedCollectionView.register(GroupSearchBarHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier)
        invitedCollectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyGroupMembersCellReuseIdentifier)
        invitedCollectionView.register(GroupMemberUserCell.self, forCellWithReuseIdentifier: groupMemberUserCellReuseIdentifier)
        
        blockedCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        blockedCollectionView.register(GroupSearchBarHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier)
        blockedCollectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyGroupMembersCellReuseIdentifier)
        blockedCollectionView.register(GroupMemberUserCell.self, forCellWithReuseIdentifier: groupMemberUserCellReuseIdentifier)
        
        membersCollectionView.delegate = self
        membersCollectionView.dataSource = self
        
        requestsCollectionView.delegate = self
        requestsCollectionView.dataSource = self
        
        invitedCollectionView.delegate = self
        invitedCollectionView.dataSource = self
        
        blockedCollectionView.delegate = self
        blockedCollectionView.dataSource = self
        /*
        collectionView.register(GroupMembersCell.self, forCellWithReuseIdentifier: groupMembershipCellReuseIdentifier)
        collectionView.register(GroupRequestCell.self, forCellWithReuseIdentifier: groupRequestsCellReuseIdentifier)
        collectionView.register(GroupInvitesCell.self, forCellWithReuseIdentifier: groupInvitesCellReuseIdentifier)
        collectionView.register(GroupBlockedCell.self, forCellWithReuseIdentifier: groupBlockedCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
         */
    }
    
    private func configureUI() {
        browserSegmentedButtonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews(browserSegmentedButtonsView, separatorView, scrollView)
        NSLayoutConstraint.activate([
            browserSegmentedButtonsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            browserSegmentedButtonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            browserSegmentedButtonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            browserSegmentedButtonsView.heightAnchor.constraint(equalToConstant: 50),
            
            separatorView.topAnchor.constraint(equalTo: browserSegmentedButtonsView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            scrollView.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        scrollView.delegate = self
        scrollView.addSubview(membersCollectionView)
        scrollView.addSubview(requestsCollectionView)
        scrollView.addSubview(invitedCollectionView)
        scrollView.addSubview(blockedCollectionView)
        
        scrollView.contentSize.width = view.frame.width * 4
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //if scrollView.contentOffset.x > scrollView.frame.width * 0.2 &&  !isFetchingOrDidFetchCases { fetchPendingCases() }
        if scrollView.contentOffset.x == 0 { return }
        
        scrollDelegate = browserSegmentedButtonsView
        scrollDelegate?.collectionViewDidScroll(for: scrollView.contentOffset.x / 4)
    }
    
    /*
    func scrollToFrame(scrollOffset : CGFloat) {
        guard scrollOffset <= membersCollectionView.contentSize.width - membersCollectionView.bounds.size.width else { return }
        guard scrollOffset >= 0 else { return }
        membersCollectionView.setContentOffset(CGPoint(x: scrollOffset, y: membersCollectionView.contentOffset.y), animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate = browserSegmentedButtonsView
        scrollDelegate?.collectionViewDidScroll(for: scrollView.contentOffset.x / 4)
    }
     */
    
    @objc func handleAdminsTap() {
        let controller = GroupAdminsViewController(group: group, userMemberType: userMemberType)
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension GroupMembershipViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return 0 }
        
        if collectionView == membersCollectionView {
            return membersLoaded ? memberUsers.isEmpty ? 1 : memberUsers.count : 0
        } else if collectionView == requestsCollectionView {
            return requestsLoaded ? memberRequests.isEmpty ? 1 : memberRequests.count : 0
        } else if collectionView == invitedCollectionView {
            return invitedLoaded ? memberInvited.isEmpty ? 1 : memberInvited.count : 0
        } else {
            return blockedLoaded ? memberBlocked.isEmpty ? 1 : memberBlocked.count : 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 65)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == membersCollectionView {
            if memberUsers.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyGroupMembersCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                cell.configure(image: nil, title: "This group has no members - yet.", description: "Invite your network to join the group", buttonText: "  Invite  ")
                //cell.delegate = self
                return cell
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupMemberUserCellReuseIdentifier, for: indexPath) as! GroupMemberUserCell
            cell.user = memberUsers[indexPath.row]
            return cell
        
        } else if collectionView == requestsCollectionView {
            if memberRequests.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyGroupMembersCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                cell.configure(image: nil, title: "No active requests", description: "Check back for all new requests.", buttonText: "  Go to group  ")
                //cell.delegate = self
                return cell
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: pendingUserCellReuseIdentifier, for: indexPath) as! GroupUserRequestCell
            cell.user = memberRequests[indexPath.row]
            //cell.delegate = self
            return cell
            
        } else if collectionView == invitedCollectionView {
            if memberInvited.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyGroupMembersCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                cell.configure(image: nil, title: "Build your community.", description: "Invite your network to join the group", buttonText: "  Invite  ")
                //cell.delegate = self
                return cell
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupMemberUserCellReuseIdentifier, for: indexPath) as! GroupMemberUserCell
            cell.user = memberInvited[indexPath.row]
            return cell
            
        } else {
            if memberBlocked.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyGroupMembersCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                cell.configure(image: nil, title: "No blocked members.", description: "Once you block a member from a group, they will be removed from the group and will no longer be able to request to join.", buttonText: "  Learn more  ")
                //cell.delegate = self
                return cell
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupMemberUserCellReuseIdentifier, for: indexPath) as! GroupMemberUserCell
            cell.user = memberBlocked[indexPath.row]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 1 { return CGSize.zero }
        return CGSize(width: view.frame.width, height: 55)
        /*
        if collectionView == membersCollectionView {
            return membersLoaded ? CGSize.zero : CGSize(width: view.frame.width, height: 55)
        } else if collectionView == requestsCollectionView {
            return requestsLoaded ? CGSize.zero : CGSize(width: view.frame.width, height: 55)
        } else if collectionView == invitedCollectionView {
            return invitedLoaded ? CGSize.zero : CGSize(width: view.frame.width, height: 55)
        } else {
            return blockedLoaded ? CGSize.zero : CGSize(width: view.frame.width, height: 55)
        }
         */
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == membersCollectionView {
            if !membersLoaded {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
                return header
            } else {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier, for: indexPath) as! GroupSearchBarHeader
                //header.delegate = self
                return header
            }
            
        } else if collectionView == requestsCollectionView {
            if !requestsLoaded {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
                return header
            } else {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier, for: indexPath) as! GroupSearchBarHeader
                //header.delegate = self
                return header
            }
        } else if collectionView == invitedCollectionView {
            if !invitedLoaded {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
                return header
            } else {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier, for: indexPath) as! GroupSearchBarHeader
                //header.delegate = self
                return header
            }
        } else {
            if !blockedLoaded {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
                return header
            } else {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier, for: indexPath) as! GroupSearchBarHeader
                //header.delegate = self
                return header
            }
        }
    }
}


extension GroupMembershipViewController: SegmentedControlDelegate {
    func indexDidChange(from currentIndex: Int, to index: Int) {
        if currentIndex == index { return }
        // Switch based on the current index of the CustomSegmentedButtonsView
        switch currentIndex {
        case 0:
            if (index == 1) {
                // Wants to move to second index
                let contentOffset = CGFloat(floor(self.scrollView.contentOffset.x + view.frame.width))
                self.moveToFrame(contentOffset: contentOffset)
            } else if index == 2 {
                // Wants to move to third index
                let contentOffset = CGFloat(floor(self.scrollView.contentOffset.x + view.frame.width * 2))
                self.moveToFrame(contentOffset: contentOffset)
            } else if (index == 3) {
                let contentOffset = CGFloat(floor(self.scrollView.contentOffset.x + view.frame.width * 3))
                self.moveToFrame(contentOffset: contentOffset)
            }
        case 1:
            if (index == 0) {
                // Wants to move to first index
                let contentOffset = CGFloat(floor(self.scrollView.contentOffset.x - view.frame.width))
                self.moveToFrame(contentOffset: contentOffset)
            } else if (index == 2) {
                let contentOffset = CGFloat(floor(self.scrollView.contentOffset.x + view.frame.width))
                self.moveToFrame(contentOffset: contentOffset)
            } else if (index == 3) {
                let contentOffset = CGFloat(floor(self.scrollView.contentOffset.x + view.frame.width * 2))
                self.moveToFrame(contentOffset: contentOffset)
            }
        case 2:
            if (index == 0) {
                let contentOffset = CGFloat(floor(self.scrollView.contentOffset.x - view.frame.width * 2))
                self.moveToFrame(contentOffset: contentOffset)
            } else if (index == 1) {
                let contentOffset = CGFloat(floor(self.scrollView.contentOffset.x - view.frame.width))
                self.moveToFrame(contentOffset: contentOffset)
            } else if (index == 3) {
                let contentOffset = CGFloat(floor(self.scrollView.contentOffset.x + view.frame.width))
                self.moveToFrame(contentOffset: contentOffset)
            }
        case 3:
            if (index == 0) {
                let contentOffset = CGFloat(floor(self.scrollView.contentOffset.x - view.frame.width * 3))
                self.moveToFrame(contentOffset: contentOffset)
            } else if (index == 1) {
                let contentOffset = CGFloat(floor(self.scrollView.contentOffset.x - view.frame.width * 2))
                self.moveToFrame(contentOffset: contentOffset)
            } else if (index == 2){
                let contentOffset = CGFloat(floor(self.scrollView.contentOffset.x - view.frame.width))
                self.moveToFrame(contentOffset: contentOffset)
            }
        default:
            print("Not found index to c hange position")
        }
    }
    
    func moveToFrame(contentOffset : CGFloat) {
        UIView.animate(withDuration: 1) {
            self.scrollView.setContentOffset(CGPoint(x: contentOffset, y: self.scrollView.bounds.origin.y), animated: true)
        }
    }
}

extension GroupMembershipViewController: GroupRequestCellDelegate {
    func didTapEmptyCellButton(membershipOption: Group.GroupMembershipManagement) {
        switch membershipOption {
        case .members:
            print("show invite view controller")
            #warning("show invite view controller")
        case .requests:
            navigationController?.popViewController(animated: true)
        case .invited:
            break
        case .blocked:
            break
        }
    }

    func didTapUser(user: User) {
        let controller = UserProfileViewController(user: user)
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

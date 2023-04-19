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

protocol GroupMembershipViewControllerDelegate: AnyObject {
    #warning("implement protocol to when user added/removed etc update previous controllers, the grouop page and the other")
}

class GroupMembershipViewController: UIViewController {
    
    private var group: Group
    
    weak var delegate: GroupBrowserViewControllerDelegate?
    
    weak var scrollDelegate: CollectionViewDidScrollDelegate?
    
    private let userMemberType: Group.MemberType
    
    private var memberUsers = [User]()
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
    
    private var isFetchingRequests: Bool = false
    private var isFetchingInvited: Bool = false
    private var isFetchingBlocked: Bool = false
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    private let membersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        layout.sectionHeadersPinToVisibleBounds = true
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        return collectionView
    }()
    
    private let requestsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        layout.sectionHeadersPinToVisibleBounds = true
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        return collectionView
    }()
    
    private let invitedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        layout.sectionHeadersPinToVisibleBounds = true
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        return collectionView
    }()
    
    private let blockedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        layout.sectionHeadersPinToVisibleBounds = true
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
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
        fetchGroupMembers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        membersCollectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: scrollView.frame.height)
        requestsCollectionView.frame = CGRect(x: view.frame.width, y: 0, width: view.frame.width, height: scrollView.frame.height)
        invitedCollectionView.frame = CGRect(x: view.frame.width * 2, y: 0, width: view.frame.width, height: scrollView.frame.height)
        blockedCollectionView.frame = CGRect(x: view.frame.width * 3, y: 0, width: view.frame.width, height: scrollView.frame.height)
    }
    
    private func configureNavigationBar() {
        title = "Manage Membership"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Admins", style: .done, target: self, action: #selector(handleAdminsTap))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
    }
    
    private func fetchGroupMembers() {
        DatabaseManager.shared.fetchGroupMembers(groupId: group.groupId) { members in
            if members.isEmpty {
                self.membersLoaded = true
                self.membersCollectionView.reloadData()
                return
            }
            
            let uids = members.map { $0.uid }
            UserService.fetchUsers(withUids: uids) { users in
                self.memberUsers = users
                self.membersLoaded = true
                self.membersCollectionView.reloadData()
            }
        }
    }
    
    private func fetchGroupUserRequests() {
        isFetchingRequests = true
        DatabaseManager.shared.fetchGroupUserRequests(groupId: group.groupId) { pendingUsers in
            if pendingUsers.isEmpty {
                self.requestsLoaded = true
                self.requestsCollectionView.reloadData()
            }
            
            let pendingUserUids = pendingUsers.map({ $0.uid })
            UserService.fetchUsers(withUids: pendingUserUids) { users in
                self.memberRequests = users
                self.requestsLoaded = true
                self.requestsCollectionView.reloadData()
            }
        }
    }
    
    private func fetchGroupInvites() {
        isFetchingInvited = true
        DatabaseManager.shared.fetchGroupInvites(groupId: group.groupId) { members in
            if members.isEmpty {
                self.invitedLoaded = true
                self.invitedCollectionView.reloadData()
                return
            }
            
            let uids = members.map { $0.uid }
            UserService.fetchUsers(withUids: uids) { users in
                self.memberInvited = users
                self.invitedLoaded = true
                self.invitedCollectionView.reloadData()
            }
        }
    }
    
    private func fetchGroupBlocked() {
        isFetchingBlocked = true
        DatabaseManager.shared.fetchGroupBlocked(groupId: group.groupId) { members in
            if members.isEmpty {
                self.blockedLoaded = true
                self.blockedCollectionView.reloadData()
                return
            }
            
            let uids = members.map { $0.uid }
            UserService.fetchUsers(withUids: uids) { users in
                self.memberBlocked = users
                self.blockedLoaded = true
                self.blockedCollectionView.reloadData()
            }
        }
    }
    
    
    
    private func configureCollectionView() {
        //membersCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: //loadingHeaderReuseIdentifier)
        membersCollectionView.register(GroupSearchBarHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier)
        membersCollectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyGroupMembersCellReuseIdentifier)
        membersCollectionView.register(GroupMemberUserCell.self, forCellWithReuseIdentifier: groupMemberUserCellReuseIdentifier)
        
        //requestsCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: //loadingHeaderReuseIdentifier)
        requestsCollectionView.register(GroupSearchBarHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier)
        requestsCollectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyGroupMembersCellReuseIdentifier)
        requestsCollectionView.register(GroupUserRequestCell.self, forCellWithReuseIdentifier: pendingUserCellReuseIdentifier)
        
        //invitedCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: //loadingHeaderReuseIdentifier)
        invitedCollectionView.register(GroupSearchBarHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier)
        invitedCollectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyGroupMembersCellReuseIdentifier)
        invitedCollectionView.register(GroupMemberUserCell.self, forCellWithReuseIdentifier: groupMemberUserCellReuseIdentifier)
        
        //blockedCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
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
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
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
        if scrollView.contentOffset.x > scrollView.frame.width * 0.2 &&  !isFetchingRequests { fetchGroupUserRequests() }
        if scrollView.contentOffset.x > scrollView.frame.width * 1.2 &&  !isFetchingInvited { fetchGroupInvites() }
        if scrollView.contentOffset.x > scrollView.frame.width * 2.2 &&  !isFetchingBlocked { fetchGroupBlocked() }
        if scrollView.contentOffset.x == 0 { return }
        
        scrollDelegate = browserSegmentedButtonsView
        scrollDelegate?.collectionViewDidScroll(for: scrollView.contentOffset.x / 4)
    }
    
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
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //if section == 0 { return 0 }
        
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
        if collectionView == membersCollectionView {
            return memberUsers.isEmpty ? CGSize(width: view.frame.width, height: collectionView.frame.height - 100) : CGSize(width: view.frame.width, height: 65)
        } else if collectionView == requestsCollectionView {
            return memberRequests.isEmpty ? CGSize(width: view.frame.width, height: collectionView.frame.height - 100) : CGSize(width: view.frame.width, height: 65)
        } else if collectionView == invitedCollectionView {
            return memberInvited.isEmpty ? CGSize(width: view.frame.width, height: collectionView.frame.height - 100) : CGSize(width: view.frame.width, height: 65)
        } else {
            return memberBlocked.isEmpty ? CGSize(width: view.frame.width, height: collectionView.frame.height - 100) : CGSize(width: view.frame.width, height: 65)
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == membersCollectionView {
            if memberUsers.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyGroupMembersCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                cell.configure(image: UIImage(named: "content.empty"), title: "This group has no members - yet.", description: "Invite your network to join the group.", buttonText: EmptyCellButtonOptions.goToGroup)
                cell.delegate = self
                return cell
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupMemberUserCellReuseIdentifier, for: indexPath) as! GroupMemberUserCell
            cell.user = memberUsers[indexPath.row]
            cell.configureMemberType(currentUserType: userMemberType, userType: .member)
            cell.delegate = self
            return cell
        
        } else if collectionView == requestsCollectionView {
            if memberRequests.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyGroupMembersCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                cell.configure(image: UIImage(named: "content.empty"), title: "No active requests.", description: "Check back for all new requests.", buttonText: EmptyCellButtonOptions.goToGroup)
                cell.delegate = self
                return cell
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: pendingUserCellReuseIdentifier, for: indexPath) as! GroupUserRequestCell
            cell.user = memberRequests[indexPath.row]
            cell.delegate = self
            return cell
            
        } else if collectionView == invitedCollectionView {
            if memberInvited.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyGroupMembersCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                cell.configure(image: UIImage(named: "content.empty"), title: "Build your community.", description: "Invite your network to join the group.", buttonText: EmptyCellButtonOptions.invite)
                cell.delegate = self
                return cell
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupMemberUserCellReuseIdentifier, for: indexPath) as! GroupMemberUserCell
            cell.user = memberInvited[indexPath.row]
            cell.configureMemberType(currentUserType: userMemberType, userType: .invited)
            cell.invitedDelegate = self
            return cell
            
        } else {
            if memberBlocked.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyGroupMembersCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                cell.configure(image: UIImage(named: "content.empty"), title: "No blocked members.", description: "Once you block a member from a group, they will be removed from the group and will no longer be able to request to join.", buttonText: EmptyCellButtonOptions.goToGroup)
                cell.delegate = self
                return cell
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupMemberUserCellReuseIdentifier, for: indexPath) as! GroupMemberUserCell
            cell.user = memberBlocked[indexPath.row]
            cell.configureMemberType(currentUserType: userMemberType, userType: .blocked)
            cell.blockDelegate = self
            return cell
        }
    }
    /*
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 1 { return CGSize.zero }
        
        if collectionView == membersCollectionView {
            return memberUsers.isEmpty ? CGSize.zero : CGSize(width: view.frame.width, height: 55)
        } else if collectionView == requestsCollectionView {
            return memberRequests.isEmpty ? CGSize.zero : CGSize(width: view.frame.width, height: 55)
        } else if collectionView == invitedCollectionView {
            return memberInvited.isEmpty ? CGSize.zero : CGSize(width: view.frame.width, height: 55)
        } else {
            return memberBlocked.isEmpty ? CGSize.zero : CGSize(width: view.frame.width, height: 55)
        }
    }
    */
    /*
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == membersCollectionView {
            if !membersLoaded {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
                return header
            } else {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier, for: indexPath) as! GroupSearchBarHeader
                header.delegate = self
                return header
            }
            
        } else if collectionView == requestsCollectionView {
            if !requestsLoaded {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
                return header
            } else {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier, for: indexPath) as! GroupSearchBarHeader
                header.delegate = self
                return header
            }
        } else if collectionView == invitedCollectionView {
            if !invitedLoaded {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
                return header
            } else {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier, for: indexPath) as! GroupSearchBarHeader
                header.delegate = self
                return header
            }
        } else {
            if !blockedLoaded {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
                return header
            } else {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier, for: indexPath) as! GroupSearchBarHeader
                header.delegate = self
                return header
            }
        }
    }
     */
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var user = User(dictionary: [:])
        
        if collectionView == membersCollectionView {
            user = memberUsers[indexPath.row]
        } else {
            return
        }
        
        let controller = UserProfileViewController(user: user)
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
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

extension GroupMembershipViewController: MESecondaryEmptyCellDelegate {
    func didTapEmptyCellButton(option: EmptyCellButtonOptions) {
        switch option {
        case .goToGroup:
            navigationController?.popViewController(animated: true)
        case .invite:
            let controller = GroupInviteViewController(group: group)
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
        case .learnMore:
            print("present learn more")
        case .dismiss:
            navigationController?.popViewController(animated: true)
        case .removeFilters:
            return
        case .comment:
            return
        }
    }
}

extension GroupMembershipViewController: GroupMemberUserCellDelegate {
    func promoteToOwner(_ cell: UICollectionViewCell, user: User) {
        guard let indexPath = membersCollectionView.indexPath(for: cell), let name = user.firstName else { return }
        DatabaseManager.shared.getNumberOfOwnersForGroup(groupId: group.groupId) { owners in
            guard owners < 5 else {
                // Group already has max number of owners
                let popUp = METopPopupView(title: "Maximum number of group owners reached.", image: "xmark.circle.fill", popUpType: .destructive)
                popUp.showTopPopup(inView: self.view)
                return
            }
            
            DatabaseManager.shared.promoteToOwner(groupId: self.group.groupId, uid: user.uid!) { promoted in
                if promoted {
                    self.membersCollectionView.performBatchUpdates {
                        self.memberUsers.remove(at: indexPath.row)
                        self.membersCollectionView.deleteItems(at: [indexPath])
                    }
                    
                    let popUp = METopPopupView(title: "\(name) is now a new owner of this group", image: "checkmark.circle.fill", popUpType: .regular)
                    popUp.showTopPopup(inView: self.view)
                }
            }
        }
    }
    
    func promoteToManager(_ cell: UICollectionViewCell, user: User) {
        guard let indexPath = membersCollectionView.indexPath(for: cell), let name = user.firstName else { return }
        DatabaseManager.shared.getNumberOfAdminsForGroup(groupId: group.groupId) { admins in
            guard admins < 10 else {
                let popUp = METopPopupView(title: "Maximum number of group managers reached.", image: "xmark.circle.fill", popUpType: .destructive)
                popUp.showTopPopup(inView: self.view)
                return
            }
            
            DatabaseManager.shared.promoteToAdmin(groupId: self.group.groupId, uid: user.uid!) { promoted in
                if promoted {
                    self.membersCollectionView.performBatchUpdates {
                        self.memberUsers.remove(at: indexPath.row)
                        self.membersCollectionView.deleteItems(at: [indexPath])
                    }
                    
                    let popUp = METopPopupView(title: "\(name) is now a new manager of this group", image: "checkmark.circle.fill", popUpType: .regular)
                    popUp.showTopPopup(inView: self.view)
                }
            }
        }
    }
    
    func removeFromGroup(_ cell: UICollectionViewCell, user: User) {
        guard let indexPath = membersCollectionView.indexPath(for: cell), let name = user.firstName else { return }
        displayMEDestructiveAlert(withTitle: "Remove from group", withMessage: "\(name) will loose access to the group content and its rights to interact within the group", withCancelButtonText: "Cancel", withDoneButtonText: "Remove") {
        
            DatabaseManager.shared.removeFromGroup(groupId: self.group.groupId, uid: user.uid!) { removed in
                if removed {
                    self.membersCollectionView.performBatchUpdates {
                        self.memberUsers.remove(at: indexPath.row)
                        self.membersCollectionView.deleteItems(at: [indexPath])
                    }
                    
                    let popUp = METopPopupView(title: "\(name) has been successfully removed from this group", image: "checkmark.circle.fill", popUpType: .regular)
                    popUp.showTopPopup(inView: self.view)
                    return
                }
            }
        }
    }
    
    func blockFromGroup(_ cell: UICollectionViewCell, user: User) {
        guard let indexPath = membersCollectionView.indexPath(for: cell), let name = user.firstName else { return }
        displayMEDestructiveAlert(withTitle: "Block from group", withMessage: "\(name) won’t be able to view the group homepage, access the group content, or interact within the group", withCancelButtonText: "Cancel", withDoneButtonText: "Block") {
            DatabaseManager.shared.blockUser(groupId: self.group.groupId, uid: user.uid!) { blocked in
                if blocked {
                    self.membersCollectionView.performBatchUpdates {
                        self.memberUsers.remove(at: indexPath.row)
                        self.membersCollectionView.deleteItems(at: [indexPath])
                    }
                    
                    let popUp = METopPopupView(title: "\(name) has been successfully blocked from this group", image: "checkmark.circle.fill", popUpType: .regular)
                    popUp.showTopPopup(inView: self.view)
                    return
                }
            }
        }
    }
}

extension GroupMembershipViewController: GroupUserRequestCellDelegate {
    func didTapAccept(_ cell: UICollectionViewCell, user: User) {
        guard let indexPath = requestsCollectionView.indexPath(for: cell), let name = user.firstName else { return }
        DatabaseManager.shared.acceptUserRequestToGroup(groupId: group.groupId, uid: user.uid!) { accepted in
            if accepted {
                self.requestsCollectionView.performBatchUpdates {
                    self.memberRequests.remove(at: indexPath.row)
                    self.requestsCollectionView.deleteItems(at: [indexPath])
                }
                
                let popUp = METopPopupView(title: "\(name) has been successfully added to this group", image: "checkmark.circle.fill", popUpType: .regular)
                popUp.showTopPopup(inView: self.view)
                return
                
            }

        }
    }
    
    func didTapIgnore(_ cell: UICollectionViewCell, user: User) {
        guard let indexPath = requestsCollectionView.indexPath(for: cell), let name = user.firstName else { return }
        DatabaseManager.shared.ignoreUserRequestToGroup(groupId: group.groupId, uid: user.uid!) { ignored in
            if ignored {
                
                self.requestsCollectionView.performBatchUpdates {
                    self.memberRequests.remove(at: indexPath.row)
                    self.requestsCollectionView.deleteItems(at: [indexPath])
                }
                
                let popUp = METopPopupView(title: "\(name) request has been ignored", image: "checkmark.circle.fill", popUpType: .regular)
                popUp.showTopPopup(inView: self.view)
                return
            }
        }
    }
}

extension GroupMembershipViewController: GroupInvitedUserCellDelegate {
    func didUnsendInvitation(_ cell: UICollectionViewCell, user: User) {
        guard let indexPath = invitedCollectionView.indexPath(for: cell), let name = user.firstName else { return }
        DatabaseManager.shared.ignoreUserRequestToGroup(groupId: group.groupId, uid: user.uid!) { ignored in
            if ignored {
                
                self.invitedCollectionView.performBatchUpdates {
                    self.memberInvited.remove(at: indexPath.row)
                    self.invitedCollectionView.deleteItems(at: [indexPath])
                }
                
                let popUp = METopPopupView(title: "Invitation to \(name) has been removed", image: "checkmark.circle.fill", popUpType: .regular)
                popUp.showTopPopup(inView: self.view)
                return
            }
        }
    }
}

extension GroupMembershipViewController: GroupBlockedUserCellDelegate {
    func didUnblockUser(_ cell: UICollectionViewCell, user: User) {
        guard let indexPath = blockedCollectionView.indexPath(for: cell), let name = user.firstName else { return }
        DatabaseManager.shared.acceptUserRequestToGroup(groupId: group.groupId, uid: user.uid!) { unblocked in
            if unblocked {
                self.blockedCollectionView.performBatchUpdates {
                    self.memberBlocked.remove(at: indexPath.row)
                    self.blockedCollectionView.deleteItems(at: [indexPath])
                }
                
                let popUp = METopPopupView(title: "\(name) has been unblocked and added to this group", image: "checkmark.circle.fill", popUpType: .regular)
                popUp.showTopPopup(inView: self.view)
                return
            }
        }
    }
}

/*
extension GroupMembershipViewController: GroupSearchBarHeaderDelegate {
    func didSearchText(text: String) {
        #warning("implementar això quan hi hagi més d'un usuari a diferents llocs per veure les searchbars sino están amagades")
        if scrollView.contentOffset.x == 0 {
            print("first text search bar")
        } else if scrollView.contentOffset.x == view.frame.width {
            print("second text search bar")
        } else if scrollView.contentOffset.x == 2 * view.frame.width {
            print("3rd text bar")
        } else {
            print("4rth text bar")
        }
    }
    
    func resetUsers() {
        
    }
    
    
}
*/

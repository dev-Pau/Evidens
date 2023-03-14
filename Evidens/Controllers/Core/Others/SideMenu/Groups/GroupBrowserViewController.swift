//
//  GroupBrowserViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/12/22.
//

import UIKit

private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"

private let groupSelectorCellReuseIdentifier = "GroupSelectorCellReuseIdentifier"
private let groupRequestSelectorCellReuseIdentifier = "GroupRequesSelectorCellReuseIdentifier"

private let groupCellReuseIdentifier = "GroupCellReuseIdentifier"
private let groupBrowseSkeletonCellReuseIdentifier = "GroupBrowseSkeletonCellReuseIdentifier"
private let groupFooterReuseIdentifier = "GroupFooterReuseIdentifier"
private let emptyGroupCellReuseIdentifier = "EmptyGroupCellReuseIdentifier"

protocol GroupBrowserViewControllerDelegate: AnyObject {
    func didTapGroupCreate()
    func didTapDiscoverGroup()
    func didSelectGroup(group: Group)
}

class GroupBrowserViewController: UIViewController {
    
    weak var delegate: GroupBrowserViewControllerDelegate?
    weak var scrollDelegate: CollectionViewDidScrollDelegate?
    
    private var memberType = [MemberTypeGroup]()
    private var groups = [Group]()
    private var pendingGroups = [Group]()
    
    private lazy var browserSegmentedButtonsView: FollowersFollowingSegmentedButtonsView = {
        let segmentedButtonsView = FollowersFollowingSegmentedButtonsView()
        segmentedButtonsView.setLabelsTitles(titles: ["Groups", "Requests"])
        segmentedButtonsView.translatesAutoresizingMaskIntoConstraints = false
        segmentedButtonsView.backgroundColor = .systemBackground
        return segmentedButtonsView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        return scrollView
    }()
   
    private lazy var shareButton: UIButton = {
        let button = UIButton()

        button.configuration = .filled()

        button.configuration?.baseBackgroundColor = primaryColor
        button.configuration?.baseForegroundColor = .white

        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 17, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("Create", attributes: container)
        
        button.addTarget(self, action: #selector(didTapCreateGroup), for: .touchUpInside)
        return button
    }()

    private let groupCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width - 30, height: 100)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private var groupsLoaded: Bool = false
    private var requestsLoaded: Bool = false
    
    private let requestsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 0)
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width - 30, height: 100)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private var requestsGroupsLoaded: Bool = false
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .quaternarySystemFill
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureCollectionView()
        fetchUserGroups()
        view.backgroundColor = .systemBackground
        browserSegmentedButtonsView.segmentedControlDelegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        groupCollectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: scrollView.frame.height)
        requestsCollectionView.frame = CGRect(x: view.frame.width, y: 0, width: view.frame.width, height: scrollView.frame.height)
    }
    
    private func fetchUserGroups() {
        DatabaseManager.shared.fetchUserIdMemberTypeGroups { memberTypeGroup in
            switch memberTypeGroup {
            case .success(let memberTypeGroup):
                self.memberType = memberTypeGroup
                let groupIds = memberTypeGroup.map({ $0.groupId })
                GroupService.fetchUserGroups(withGroupIds: groupIds) { groups in
                    self.groups = groups
                    self.groupsLoaded = true
                    self.groupCollectionView.reloadData()
                }
            case .failure(_):
                self.groupsLoaded = true
                self.groupCollectionView.reloadData()
            }
        }
    }
    
    
    private func fetchUserPendingGroups() {
        requestsGroupsLoaded = true
        DatabaseManager.shared.fetchUserIdPendingGroups { memberTypeGroup in
            switch memberTypeGroup {
            case .success(let memberTypeGroup):
                let groupIds = memberTypeGroup.map({ $0.groupId })
                GroupService.fetchUserGroups(withGroupIds: groupIds) { groups in
                    self.pendingGroups = groups
                    self.requestsLoaded = true
                    self.requestsCollectionView.reloadData()
                }
            case .failure(_):
                self.requestsLoaded = true
                self.requestsCollectionView.reloadData()
            }
            
        }
    }
    
    private func configureNavigationBar() {
        title = "Groups"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.systemBlue), style: .done, target: self, action: #selector(didTapCreateGroup))
    }
    
    private func configureCollectionView() {
        groupCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        groupCollectionView.register(GroupBrowseCell.self, forCellWithReuseIdentifier: groupCellReuseIdentifier)
        groupCollectionView.register(GroupBrowseFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: groupFooterReuseIdentifier)
        groupCollectionView.register(MEPrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyGroupCellReuseIdentifier)
        groupCollectionView.delegate = self
        groupCollectionView.dataSource = self
        
        requestsCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        requestsCollectionView.register(GroupBrowseCell.self, forCellWithReuseIdentifier: groupCellReuseIdentifier)
        requestsCollectionView.register(GroupBrowseFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: groupFooterReuseIdentifier)
        requestsCollectionView.register(MEPrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyGroupCellReuseIdentifier)
        requestsCollectionView.delegate = self
        requestsCollectionView.dataSource = self
    }
    
    private func configureUI() {
        browserSegmentedButtonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews(browserSegmentedButtonsView, scrollView, separatorView)
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
        scrollView.addSubview(groupCollectionView)
        scrollView.addSubview(requestsCollectionView)
        scrollView.contentSize.width = view.frame.width * 2
    }
  
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x > scrollView.frame.width * 0.2 &&  !requestsGroupsLoaded { fetchUserPendingGroups() }
        if scrollView.contentOffset.x == 0 { return }
        
        scrollDelegate = browserSegmentedButtonsView
        scrollDelegate?.collectionViewDidScroll(for: scrollView.contentOffset.x / 2)
    }
    
    @objc func didTapCreateGroup() {
        let controller = CreateGroupViewController()
        
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        
        present(nav, animated: true)
    }
}

extension GroupBrowserViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == groupCollectionView {
            return groupsLoaded ? groups.count > 0 ? groups.count : 1 : 0
        } else {
            return requestsLoaded ? pendingGroups.count > 0 ? pendingGroups.count : 1 : 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView == groupCollectionView {
            if groups.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyGroupCellReuseIdentifier, for: indexPath) as! MEPrimaryEmptyCell
                cell.set(withImage: UIImage(named: "groups.empty")!, withTitle: "We could not find any group you are a part of - yet.", withDescription: "Discover listed groups or communities that share your interests, vision or goals.", withButtonText: "Discover")
                cell.delegate = self
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupCellReuseIdentifier, for: indexPath) as! GroupBrowseCell
                cell.viewModel = GroupViewModel(group: groups[indexPath.row])
                
                let memberIndex = memberType.firstIndex { memberType in
                    if groups[indexPath.row].groupId == memberType.groupId {
                        return true
                    }
                    return false
                }
                
                if let memberIndex = memberIndex { cell.setGroupRole(role: memberType[memberIndex].memberType) }
              
                return cell
            }
            
        } else {
            if pendingGroups.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyGroupCellReuseIdentifier, for: indexPath) as! MEPrimaryEmptyCell
                cell.delegate = self
                cell.set(withImage: UIImage(named: "groups.empty")!, withTitle: "We could not find any active group requests.", withDescription: "Discover listed groups or communities that share your interests, vision or goals.", withButtonText: "Discover")
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupCellReuseIdentifier, for: indexPath) as! GroupBrowseCell
                cell.viewModel = GroupViewModel(group: pendingGroups[indexPath.row])
                cell.setGroupRole(role: .pending)
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if collectionView == groupCollectionView {
            return groupsLoaded ? CGSize.zero : CGSize(width: view.frame.width - 30, height: 50)
        } else {
            return requestsLoaded ? CGSize.zero : CGSize(width: view.frame.width - 30, height: 50)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {

        if collectionView == groupCollectionView {
            return groups.isEmpty || !groupsLoaded ? CGSize.zero : CGSize(width: view.frame.width - 30, height: 50)
        } else {
            return pendingGroups.isEmpty || !requestsLoaded ? CGSize.zero : CGSize(width: view.frame.width - 30, height: 50)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if collectionView == groupCollectionView {
                let header = groupCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
                return header
            } else {
                let header = requestsCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
                return header
            }
        } else {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: groupFooterReuseIdentifier, for: indexPath) as! GroupBrowseFooter
            footer.delegate = self
            return footer
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == groupCollectionView {
            guard !groups.isEmpty else { return }
            let group = groups[indexPath.row]
            
            let memberIndex = memberType.firstIndex { memberType in
                if group.groupId == memberType.groupId {
                    return true
                }
                return false
            }
            
            let controller = GroupPageViewController(group: group, memberType: memberType[memberIndex!].memberType)
            controller.delegate = self
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
        } else {
            guard !pendingGroups.isEmpty else { return }
            let group = pendingGroups[indexPath.row]
            let controller = GroupPageViewController(group: group, memberType: Group.MemberType.pending)
            controller.delegate = self
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}


extension GroupBrowserViewController: GroupPageViewControllerDelegate {
    func didUpdateGroup(_ group: Group) {
        let index = groups.firstIndex { currentGroup in
            if group.groupId == currentGroup.groupId {
                return true
            }
            
            return false
        }
        
        if let index = index {
            groups[index] = group
            groupCollectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
        }
    }
}

extension GroupBrowserViewController: SegmentedControlDelegate {
    func indexDidChange(from currentIndex: Int, to index: Int) {
        if currentIndex == index { return }
        switch currentIndex {
        case 0:
            
            let contentOffset = CGFloat(floor(self.scrollView.contentOffset.x + view.frame.width))
            self.moveToFrame(contentOffset: contentOffset)
            
        case 1:
            
            let contentOffset = CGFloat(floor(self.scrollView.contentOffset.x - view.frame.width))
            self.moveToFrame(contentOffset: contentOffset)
            
        default:
            print("Not found index to change position")
        }
    }
    
    func moveToFrame(contentOffset : CGFloat) {
        UIView.animate(withDuration: 1) {
            self.scrollView.setContentOffset(CGPoint(x: contentOffset, y: self.scrollView.bounds.origin.y), animated: true)
        }
        
    }
}

extension GroupBrowserViewController: EmptyGroupCellDelegate {
    func didTapDiscoverGroup() {
        let controller = DiscoverGroupsViewController()
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension GroupBrowserViewController: GroupBrowseFooterDelegate {
    func didTapDiscoverGroups() {
        let controller = DiscoverGroupsViewController()
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

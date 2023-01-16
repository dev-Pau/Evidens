//
//  GroupBrowserViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/12/22.
//

import UIKit

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
    
    private let browserSegmentedButtonsView = FollowersFollowingSegmentedButtonsView(frame: .zero, titles: ["Groups", "Requests"])
    
    private var loaded: Bool = false
    
    private var groups = [Group]()
    
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
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .horizontal
        //layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        //layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width - 30, height: 100)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        return collectionView
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureCollectionView()
        view.backgroundColor = .systemBackground
        browserSegmentedButtonsView.segmentedControlDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !loaded { groupCollectionView.reloadData() }
    }
    
    private func configureNavigationBar() {
        title = "Groups"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.systemBlue), style: .done, target: self, action: #selector(didTapCreateGroup))
        
    }
    
    private func configureCollectionView() {
        //groupCollectionView.register(GroupBrowseSkeletonCell.self, forCellWithReuseIdentifier: groupBrowseSkeletonCellReuseIdentifier)
        //groupCollectionView.register(GroupBrowseCell.self, forCellWithReuseIdentifier: groupCellReuseIdentifier)
        //groupCollectionView.register(GroupBrowseFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: groupFooterReuseIdentifier)
        //groupCollectionView.register(EmptyGroupCell.self, forCellWithReuseIdentifier: emptyGroupCellReuseIdentifier)
        groupCollectionView.register(GroupSelectorCell.self, forCellWithReuseIdentifier: groupSelectorCellReuseIdentifier)
        groupCollectionView.register(RequestSelectorCell.self, forCellWithReuseIdentifier: groupRequestSelectorCellReuseIdentifier)
        groupCollectionView.delegate = self
        groupCollectionView.dataSource = self
    }
    
    private func configureUI() {
        browserSegmentedButtonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews(browserSegmentedButtonsView, groupCollectionView)
        NSLayoutConstraint.activate([
            browserSegmentedButtonsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            browserSegmentedButtonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            browserSegmentedButtonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            browserSegmentedButtonsView.heightAnchor.constraint(equalToConstant: 51),
            
            groupCollectionView.topAnchor.constraint(equalTo: browserSegmentedButtonsView.bottomAnchor),
            groupCollectionView.leadingAnchor.constraint(equalTo: browserSegmentedButtonsView.leadingAnchor),
            groupCollectionView.trailingAnchor.constraint(equalTo: browserSegmentedButtonsView.trailingAnchor),
            groupCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func scrollToFrame(scrollOffset : CGFloat) {
        guard scrollOffset <= groupCollectionView.contentSize.width - groupCollectionView.bounds.size.width else { return }
        guard scrollOffset >= 0 else { return }
        groupCollectionView.setContentOffset(CGPoint(x: scrollOffset, y: groupCollectionView.contentOffset.y), animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: groupCollectionView.frame.height)//self.view.frame.height - 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupSelectorCellReuseIdentifier, for: indexPath) as! GroupSelectorCell
            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupRequestSelectorCellReuseIdentifier, for: indexPath) as! RequestSelectorCell
            return cell
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

extension GroupBrowserViewController: GroupSelectorCellDelegate {
    func didSelectGroup(_ group: Group, memberType: Group.MemberType) {
        let controller = GroupPageViewController(group: group, memberType: memberType)
        controller.delegate = self
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func didTapDiscover() {
        let controller = DiscoverGroupsViewController()
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension GroupBrowserViewController: SegmentedControlDelegate {
    func indexDidChange(from currentIndex: Int, to index: Int) {
        if currentIndex == index { return }
        let collectionBounds = self.groupCollectionView.bounds
        // Switch based on the current index of the CustomSegmentedButtonsView
        switch currentIndex {
        case 0:
            
            let contentOffset = CGFloat(floor(self.groupCollectionView.contentOffset.x + collectionBounds.size.width))
            self.moveToFrame(contentOffset: contentOffset)
            
        case 1:
            
            let contentOffset = CGFloat(floor(self.groupCollectionView.contentOffset.x - collectionBounds.size.width))
            self.moveToFrame(contentOffset: contentOffset)
            
        default:
            print("Not found index to change position")
        }
    }
    
    func moveToFrame(contentOffset : CGFloat) {
        UIView.animate(withDuration: 1) {
            let frame: CGRect = CGRect(x : contentOffset ,y : self.groupCollectionView.contentOffset.y ,width : self.groupCollectionView.frame.width, height: self.groupCollectionView.frame.height)
            self.groupCollectionView.scrollRectToVisible(frame, animated: true)
        }
        
    }
}

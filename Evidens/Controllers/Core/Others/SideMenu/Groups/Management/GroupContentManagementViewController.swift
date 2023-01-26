//
//  GroupContentManagementViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/1/23.
//

import UIKit



private let postsReviewCellReuseIdentifier = "PostsReviewCellReuseIdentifier"
private let casesReviewCellReuseIdentifier = "CasesReviewCellReuseIdentifier"

class GroupContentManagementViewController: UIViewController {
    
    let group: Group
    
    weak var delegate: GroupBrowserViewControllerDelegate?
    
    weak var scrollDelegate: CollectionViewDidScrollDelegate?
    
    private lazy var browserSegmentedButtonsView: FollowersFollowingSegmentedButtonsView = {
        let segmentedButtonsView = FollowersFollowingSegmentedButtonsView()
        //segmentedButtonsView.setLabelsTitles(titles: ["Members", "Requests", "Invites", "Blocked"])
        segmentedButtonsView.setLabelsTitles(titles: ["Posts", "Cases"])
        segmentedButtonsView.translatesAutoresizingMaskIntoConstraints = false
        segmentedButtonsView.backgroundColor = .systemBackground
        return segmentedButtonsView
    }()
    
    private var groups = [Group]()
    
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
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isPagingEnabled = true
        return collectionView
    }()
    
    init(group: Group) {
        self.group = group
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
    
    private func configureNavigationBar() {
        title = "Pending content"
    }
    
    private func configureCollectionView() {
        groupCollectionView.register(PendingPostsCell.self, forCellWithReuseIdentifier: postsReviewCellReuseIdentifier)
        groupCollectionView.register(PendingCasesCell.self, forCellWithReuseIdentifier: casesReviewCellReuseIdentifier)
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
}

extension GroupContentManagementViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: groupCollectionView.frame.height)//self.view.frame.height - 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postsReviewCellReuseIdentifier, for: indexPath) as! PendingPostsCell
            //cell.group = group
            cell.groupId = group.groupId
            cell.fetchPendingPosts(group: group)
            cell.reviewPostCellDelegate = self
            //cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: casesReviewCellReuseIdentifier, for: indexPath) as! PendingCasesCell
            cell.groupId = group.groupId
            cell.fetchPendingPosts(group: group)
            cell.reviewPostCellDelegate = self
            //cell.delegate = self
            return cell
        }
    }
}

/*
extension GroupContentManagementViewController: GroupPageViewControllerDelegate {
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

extension GroupContentManagementViewController: GroupSelectorCellDelegate {
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
 */

extension GroupContentManagementViewController: SegmentedControlDelegate {
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

extension GroupContentManagementViewController: PresentReviewAlertContentGroupDelegate {

    func didAcceptContent(type: ContentGroup.GroupContentType) {
        let title = type == .post ? "post" : "case"
        
        let approvedPostPopup = METopPopupView(title: "Pending \(title) approved. It may take a few minutes to appear in the group feed.", image: "checkmark.circle.fill")
        approvedPostPopup.showTopPopup(inView: self.view)
    }
    
    func showDeleteAlertController(type: ContentGroup.GroupContentType, contentId: String) {
        let title = type == .post ? "post" : "case"
        let position = type == .post ? 0 : 1
        
        displayMEDestructiveAlert(withTitle: "Delete \(title)", withMessage: "Are you sure you want to delete this \(title)?", withCancelButtonText: "Cancel", withDoneButtonText: "Delete") {
            if position == 0 {
                let cell = self.groupCollectionView.cellForItem(at: IndexPath(item: position, section: 0)) as! PendingPostsCell
                cell.deleteSelectedContent(contentId: contentId)
            } else {
                let cell = self.groupCollectionView.cellForItem(at: IndexPath(item: position, section: 0)) as! PendingCasesCell
                cell.deleteSelectedContent(contentId: contentId)
            }
            
        }
    }
    
    func didCancelContent(type: ContentGroup.GroupContentType) {
        let capitalTitle = type == .post ? "Post" : "Case"
        let deletedPostPopup = METopPopupView(title: "\(capitalTitle) successfully deleted", image: "checkmark.circle.fill")
        deletedPostPopup.showTopPopup(inView: self.view)
    }
    
    func wantsToSeePost(post: Post, user: User) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        //self.navigationController?.delegate = self
        
        let controller = DetailsPostViewController(post: post, user: user, collectionViewLayout: layout)
        controller.isReviewingPost = true
        controller.reviewDelegate = self
        controller.groupId = group.groupId
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func wantsToSeeProfile(user: User) {
        let controller = UserProfileViewController(user: user)
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension GroupContentManagementViewController: DetailsContentReviewDelegate {
    func didTapAcceptContent(type: ContentGroup.GroupContentType, contentId: String) {
        let position = type == .post ? 0 : 1
        
        if position == 0 {
            let cell = self.groupCollectionView.cellForItem(at: IndexPath(item: position, section: 0)) as! PendingPostsCell
            cell.deletePendingItem(contentId: contentId)
            
        } else {
            let cell = self.groupCollectionView.cellForItem(at: IndexPath(item: position, section: 0)) as! PendingCasesCell
            //cell.deleteSelectedContent(contentId: contentId)
        }
    }
    
    func didTapCancelContent(type: ContentGroup.GroupContentType, contentId: String) {
        
    }
    
}


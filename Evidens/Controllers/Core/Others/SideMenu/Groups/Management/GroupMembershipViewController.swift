//
//  GroupMembershipViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/1/23.
//

import UIKit

private let groupMembershipCellReuseIdentifier = "GroupMembershipCellReuseIdentifier"
private let groupRequestsCellReuseIdentifier = "GroupInvitesCellReuseIdentifier"

class GroupMembershipViewController: UIViewController {
    
    private var group: Group
    
    weak var delegate: GroupBrowserViewControllerDelegate?
    
    weak var scrollDelegate: CollectionViewDidScrollDelegate?
    
    private lazy var browserSegmentedButtonsView: CustomSegmentedButtonsView = {
        let segmentedButtonsView = CustomSegmentedButtonsView()
        segmentedButtonsView.setLabelsTitles(titles: ["Members", "Requests", "Invited", "Blocked"])
        segmentedButtonsView.translatesAutoresizingMaskIntoConstraints = false
        segmentedButtonsView.backgroundColor = .systemBackground
        return segmentedButtonsView
    }()
    
    private var loaded: Bool = false
    
    private var groups = [Group]()
    
    private let collectionView: UICollectionView = {
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
        title = "Manage membership"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Admins", style: .done, target: self, action: #selector(handleAdminsTap))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
    }
    
    
    
    private func configureCollectionView() {
        collectionView.register(GroupMembersCell.self, forCellWithReuseIdentifier: groupMembershipCellReuseIdentifier)
        collectionView.register(GroupRequestCell.self, forCellWithReuseIdentifier: groupRequestsCellReuseIdentifier)
        //groupCollectionView.register(GroupSelectorCell.self, forCellWithReuseIdentifier: groupSelectorCellReuseIdentifier)
        //groupCollectionView.register(RequestSelectorCell.self, forCellWithReuseIdentifier: groupRequestSelectorCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func configureUI() {
        browserSegmentedButtonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews(browserSegmentedButtonsView, collectionView)
        NSLayoutConstraint.activate([
            browserSegmentedButtonsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            browserSegmentedButtonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            browserSegmentedButtonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            browserSegmentedButtonsView.heightAnchor.constraint(equalToConstant: 51),
            
            collectionView.topAnchor.constraint(equalTo: browserSegmentedButtonsView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: browserSegmentedButtonsView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: browserSegmentedButtonsView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func scrollToFrame(scrollOffset : CGFloat) {
        guard scrollOffset <= collectionView.contentSize.width - collectionView.bounds.size.width else { return }
        guard scrollOffset >= 0 else { return }
        collectionView.setContentOffset(CGPoint(x: scrollOffset, y: collectionView.contentOffset.y), animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate = browserSegmentedButtonsView
        scrollDelegate?.collectionViewDidScroll(for: scrollView.contentOffset.x / 4)
    }
    
    @objc func handleAdminsTap() {
        #warning("present admins controller omegakek")
    }
}

extension GroupMembershipViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.collectionView.frame.height)//self.view.frame.height - 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupMembershipCellReuseIdentifier, for: indexPath) as! GroupMembersCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupRequestsCellReuseIdentifier, for: indexPath) as! GroupRequestCell
            cell.delegate = self
            cell.group = group
            return cell
        }
    }
}


extension GroupMembershipViewController: SegmentedControlDelegate {
    func indexDidChange(from currentIndex: Int, to index: Int) {
        if currentIndex == index { return }
        let collectionBounds = self.collectionView.bounds
        // Switch based on the current index of the CustomSegmentedButtonsView
        switch currentIndex {
        case 0:
            if (index == 1) {
                // Wants to move to second index
                let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x + collectionBounds.size.width))
                self.moveToFrame(contentOffset: contentOffset)
            } else if index == 2 {
                // Wants to move to third index
                let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x + collectionBounds.size.width * 2))
                self.moveToFrame(contentOffset: contentOffset)
            } else if (index == 3) {
                let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x + collectionBounds.size.width * 3))
                self.moveToFrame(contentOffset: contentOffset)
            }
        case 1:
            if (index == 0) {
                // Wants to move to first index
                let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x - collectionBounds.size.width))
                self.moveToFrame(contentOffset: contentOffset)
            } else if (index == 2) {
                let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x + collectionBounds.size.width))
                self.moveToFrame(contentOffset: contentOffset)
            } else if (index == 3) {
                let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x + collectionBounds.size.width * 2))
                self.moveToFrame(contentOffset: contentOffset)
            }
        case 2:
            if (index == 0) {
                let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x - collectionBounds.size.width * 2))
                self.moveToFrame(contentOffset: contentOffset)
            } else if (index == 1) {
                let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x - collectionBounds.size.width))
                self.moveToFrame(contentOffset: contentOffset)
            } else if (index == 3) {
                let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x + collectionBounds.size.width))
                self.moveToFrame(contentOffset: contentOffset)
            }
        case 3:
            if (index == 0) {
                let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x - collectionBounds.size.width * 3))
                self.moveToFrame(contentOffset: contentOffset)
            } else if (index == 1) {
                let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x - collectionBounds.size.width * 2))
                self.moveToFrame(contentOffset: contentOffset)
            } else if (index == 2){
                let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x - collectionBounds.size.width * 1))
                self.moveToFrame(contentOffset: contentOffset)
            }
        default:
            print("Not found index to c hange position")
        }
    }
    
    func moveToFrame(contentOffset : CGFloat) {
        UIView.animate(withDuration: 1) {
            let frame: CGRect = CGRect(x : contentOffset ,y : self.collectionView.contentOffset.y ,width : self.collectionView.frame.width, height: self.collectionView.frame.height)
            self.collectionView.scrollRectToVisible(frame, animated: true)
        }
        
    }
}

extension GroupMembershipViewController: GroupRequestCellDelegate {
    func didTapEmptyCellButton() {
        navigationController?.popViewController(animated: true)
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

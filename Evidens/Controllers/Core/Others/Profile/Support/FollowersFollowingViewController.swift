//
//  FollowersFollowingViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 4/10/22.
//

import UIKit

private let usersFollowerReuseIdentifierCell = "UsersFollowerReuseIdentifierCell"
private let usersFollowingReuseIdentifierCell = "UsersFollowingReuseIdentifierCell"

class FollowersFollowingViewController: UIViewController {
    
    private let user: User
    
    weak var delegate: CollectionViewDidScrollDelegate?
    
    private let topics = ["Followers", "Following"]
    
    
    private lazy var segmentedButtonsView: FollowersFollowingSegmentedButtonsView = {
        let segmentedButtonsView = FollowersFollowingSegmentedButtonsView()
        segmentedButtonsView.setLabelsTitles(titles: topics)
        segmentedButtonsView.translatesAutoresizingMaskIntoConstraints = false
        segmentedButtonsView.backgroundColor = .systemBackground
        return segmentedButtonsView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.scrollDirection = .horizontal
        collectionViewFlowLayout.minimumLineSpacing = 1
        collectionViewFlowLayout.minimumInteritemSpacing = 1
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure()
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = user.firstName
    }
    
    private func configure() {
        collectionView.register(FollowersCell.self, forCellWithReuseIdentifier: usersFollowerReuseIdentifierCell)
        collectionView.register(FollowingCell.self, forCellWithReuseIdentifier: usersFollowingReuseIdentifierCell)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        segmentedButtonsView.segmentedControlDelegate = self
        
        view.backgroundColor = .systemBackground
        view.addSubviews(segmentedButtonsView, collectionView)
        NSLayoutConstraint.activate([
            segmentedButtonsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            segmentedButtonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            segmentedButtonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            segmentedButtonsView.heightAnchor.constraint(equalToConstant: 51),
            
            collectionView.topAnchor.constraint(equalTo: segmentedButtonsView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func scrollToFrame(scrollOffset : CGFloat) {
        guard scrollOffset <= collectionView.contentSize.width - collectionView.bounds.size.width else { return }
        guard scrollOffset >= 0 else { return }
        collectionView.setContentOffset(CGPoint(x: scrollOffset, y: collectionView.contentOffset.y), animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate = segmentedButtonsView
        delegate?.collectionViewDidScroll(for: scrollView.contentOffset.x / 2)
    }
}

extension FollowersFollowingViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: usersFollowerReuseIdentifierCell, for: indexPath) as! FollowersCell
            cell.user = user
            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: usersFollowingReuseIdentifierCell, for: indexPath) as! FollowingCell
            cell.user = user
            cell.delegate = self
            return cell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.view.frame.height - 150)
    }
}

extension FollowersFollowingViewController: FollowingFollowerCellDelegate {
    func didTapUser(_ user: User) {
        let controller = UserProfileViewController(user: user)
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: - SegmentedControlDelegate

extension FollowersFollowingViewController: SegmentedControlDelegate {
    func indexDidChange(from currentIndex: Int, to index: Int) {
        if currentIndex == index { return }
        let collectionBounds = self.collectionView.bounds
        // Switch based on the current index of the CustomSegmentedButtonsView
        switch currentIndex {
        case 0:
            
            let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x + collectionBounds.size.width))
            self.moveToFrame(contentOffset: contentOffset)
            
        case 1:
            
            let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x - collectionBounds.size.width))
            self.moveToFrame(contentOffset: contentOffset)
            
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

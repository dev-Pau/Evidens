//
//  ProfileViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/21.
//


import UIKit


private let headerIdentifier = "ProfileHeader"
private let cellIdentifier = "ProfileCell"

class ProfileViewController: UICollectionViewController {
    
    //MARK: - Properties

    private var user: User
    
    //MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureNavigationItemButton()
        configureNavigationBar()
        checkIfUserIsFollowed()
        fetchUserStats()

    }
    
    //MARK: - API
    
    func fetchUserStats() {
        UserService.fetchUserStats(uid: user.uid!) { stats in
            self.user.stats = stats
            self.collectionView.reloadData()
        }
    }
    
    func checkIfUserIsFollowed() {
        UserService.checkIfUserIsFollowed(uid: user.uid!) { isFollowed in
            self.user.isFollowed = isFollowed
            self.collectionView.reloadData()
        }
    }

    
    //MARK: - Helpers
    
    func configureCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
    }
    
    func configureNavigationItemButton() {
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: .init(systemName: "gear"), style: .plain, target: self, action: #selector(didTapSettings)), UIBarButtonItem(image: .init(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(didTapSettings))]
        navigationItem.rightBarButtonItems?[0].tintColor = .black
        navigationItem.rightBarButtonItems?[1].tintColor = .black
    }
    
    func configureNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    //MARK: - Actions
    @objc func didTapSettings() {
        let controller = SettingsViewController()
        
        if let presentationController = controller.presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium()]
        }
        self.present(controller, animated: true)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let magicalSafeAreaTop = topbarHeight
        let offset = scrollView.contentOffset.y + magicalSafeAreaTop
        
        let alpha: CGFloat = 1 - ((scrollView.contentOffset.y + magicalSafeAreaTop) / magicalSafeAreaTop)
        navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, -offset))
        
        navigationItem.rightBarButtonItems?[0].tintColor = .black.withAlphaComponent(alpha)
        navigationItem.rightBarButtonItems?[1].tintColor = .black.withAlphaComponent(alpha)
    }
    

}

//MARK: - UICollectionViewDataSource

extension ProfileViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ProfileCell
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! ProfileHeader
        header.delegate = self

        header.viewModel = ProfileHeaderViewModel(user: user)
        
        return header
    }
}

//MARK: - UICollectionViewDelegate


//MARK: - UICollectionViewDelegateFlowLayout

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 240)
    }
}

//MARK: - ProfileHeaderDelegate

extension ProfileViewController: ProfileHeaderDelegate {
    
    func header(_ profileHeader: ProfileHeader, didTapActionButtonFor user: User) {
        if user.isCurrentUser {
            //Handle edit profile
            print("your profile")
        }
        
        else if user.isFollowed {
            //Handle unfollow user
            UserService.unfollow(uid: user.uid!) { error in
                //Did follow user
                self.user.isFollowed = false
                //Update user unfollow stats
                self.fetchUserStats()
            }
        } else {
            //Handle follow user
            UserService.follow(uid: user.uid!) { error in
                //Did follow user
                self.user.isFollowed = true
                //Update user follow stats
                self.fetchUserStats()
            }
            
        }
    }
    
    func updateProfileImage(_ profileHeader: ProfileHeader, didTapChangeProfilePicFor user: User) {
        
        let controller = ProfileImageViewController()
        controller.hidesBottomBarWhenPushed = true

        if user.isCurrentUser {
            print("DEBUG: Is current user, let change profile image here")
            navigationController?.pushViewController(controller, animated: true)
        } else {
            print("DEBUG: Is not current user, let change profile image here")
            //button is public, implement with private!
            controller.editProfileButton.isHidden = true
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}


extension ProfileViewController {
    //Get height of status bar + navigation bar
    var topbarHeight: CGFloat {
        return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
}



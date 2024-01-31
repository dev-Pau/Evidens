//
//  HomeOnboardingViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/2/23.
//

import UIKit

private let onboardingHeaderReuseIdentifier = "OnboardingHeaderReuseIdentifier"

protocol HomeOnboardingViewControllerDelegate: AnyObject {
    func didUpdateUser(user: User)
}

class HomeOnboardingViewController: UIViewController {
    
    weak var delegate: HomeOnboardingViewControllerDelegate?
    private var viewModel: HomeOnboardingViewModel
    
    private var collectionView: UICollectionView!

    init(user: User) {
        self.viewModel = HomeOnboardingViewModel(user: user)
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        configureUI()
        configureNotificationObservers()
    }
    
    private func configureNavigationBar() {
        title = AppStrings.Title.connect
    }
    
    private func configureNotificationObservers() {
       
        NotificationCenter.default.addObserver(self, selector: #selector(userDidChange(notification:)), name: NSNotification.Name(AppPublishers.Names.refreshUser), object: nil)
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        
        collectionView.register(OnboardingHomeHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: onboardingHeaderReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: strongSelf.viewModel.users.isEmpty ? .fractionalWidth(1) : .absolute(63))
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(400))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
            let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
            
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [header]
            return section
        }
        
        return layout
    }
}

extension HomeOnboardingViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: onboardingHeaderReuseIdentifier, for: indexPath) as! OnboardingHomeHeader
        header.delegate = self
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        return
    }
}

extension HomeOnboardingViewController: OnboardingHomeHeaderDelegate {
    
    func didTapConfigureProfile() {
        let controller = ImageViewController(user: viewModel.user)
        controller.comesFromHomeOnboarding = true
        
        let navVC = UINavigationController(rootViewController: controller)
        navVC.modalPresentationStyle = .fullScreen

        present(navVC, animated: true)
    }
    
    @objc func userDidChange(notification: NSNotification) {
        if let user = notification.userInfo!["user"] as? User {
            delegate?.didUpdateUser(user: user)
            
            viewModel.update(user: user)
            
            let controller = UserProfileViewController(user: user)
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

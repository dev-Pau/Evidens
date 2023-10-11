//
//  HomeOnboardingViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/2/23.
//

import UIKit

private let loadingCellReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let onboardingHeaderReuseIdentifier = "OnboardingHeaderReuseIdentifier"
private let connectCellReuseIdentifier = "ConnectCellReuseIdentifier"
private let emptyContentCellReuseIdentifier = "EmptyContentCellReuseIdentifier"

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
        fetchUsers()
    }
    
    private func fetchUsers() {
        viewModel.fetchUsers { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.reloadData()
            
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            }
        }
    }
    
    private func configureNavigationBar() {
        title = AppStrings.Title.connect
    }
    
    private func configureNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(connectionDidChange(_:)), name: NSNotification.Name(AppPublishers.Names.connectUser), object: nil)
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
        
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingCellReuseIdentifier)
        collectionView.register(OnboardingHomeHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: onboardingHeaderReuseIdentifier)
        collectionView.register(ConnectUserCell.self, forCellWithReuseIdentifier: connectCellReuseIdentifier)
        collectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: strongSelf.viewModel.users.isEmpty ? .fractionalWidth(1) : .absolute(73))
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(55))
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if viewModel.followersLoaded {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: onboardingHeaderReuseIdentifier, for: indexPath) as! OnboardingHomeHeader
            header.delegate = self
            return header
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingCellReuseIdentifier, for: indexPath) as! MELoadingHeader
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if viewModel.users.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
            cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Content.User.emptyTitle, description: AppStrings.Content.User.emptyContent, content: .dismiss)
            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: connectCellReuseIdentifier, for: indexPath) as! ConnectUserCell
            cell.viewModel = ConnectViewModel(user: viewModel.users[indexPath.row])
            cell.connectionDelegate = self
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = viewModel.users[indexPath.row]
        let controller = UserProfileViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension HomeOnboardingViewController: OnboardingHomeHeaderDelegate {
    func didTapConfigureProfile() {
        let controller = ImageViewController(user: viewModel.user)
        controller.comesFromHomeOnboarding = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(userDidChange(notification:)), name: NSNotification.Name(AppPublishers.Names.refreshUser), object: nil)
        
        let navVC = UINavigationController(rootViewController: controller)
        navVC.modalPresentationStyle = .fullScreen

        present(navVC, animated: true)
    }
    
    @objc func userDidChange(notification: NSNotification) {
        if let user = notification.userInfo!["user"] as? User {
            delegate?.didUpdateUser(user: user)
            let controller = UserProfileViewController(user: user)
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension HomeOnboardingViewController: ConnectUserCellDelegate {
    func didConnect(_ cell: UICollectionViewCell, connection: UserConnection) {
        
        guard let cell = cell as? ConnectUserCell, let indexPath = collectionView.indexPath(for: cell) else { return }
        guard let tab = self.tabBarController as? MainTabController, let currentUser = tab.user else { return }
        
        let user = viewModel.users[indexPath.row]
        
        switch connection.phase {
            
        case .connected:
            
            displayAlert(withTitle: AppStrings.Alerts.Title.remove, withMessage: AppStrings.Alerts.Subtitle.remove, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.withdraw, style: .destructive) { [weak self] in
                guard let strongSelf = self else { return }
                
                cell.disableButton()
                
                strongSelf.viewModel.unconnect(withUser: user) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    cell.enableButton()
                    
                    if let error {
                        strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                    } else {
                        
                        cell.viewModel?.set(phase: .unconnect)
                        strongSelf.userDidChangeConnection(uid: user.uid!, phase: .unconnect)
                    }
                }
            }
        case .pending:
            displayAlert(withTitle: AppStrings.Alerts.Title.withdraw, withMessage: AppStrings.Alerts.Subtitle.withdraw, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.withdraw, style: .destructive) { [weak self] in
                guard let strongSelf = self else { return }
                
                cell.disableButton()
                
                strongSelf.viewModel.withdraw(withUser: user) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    cell.enableButton()
                    
                    if let error {
                        strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                    } else {
                        cell.viewModel?.set(phase: .withdraw)
                        strongSelf.userDidChangeConnection(uid: user.uid!, phase: .withdraw)
                    }
                }
            }
        case .received:
            
            cell.disableButton()
            
            viewModel.accept(withUser: user, currentUser: currentUser) { [weak self] error in
                guard let strongSelf = self else { return }
                
                cell.enableButton()
                
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    cell.viewModel?.set(phase: .connected)
                    strongSelf.userDidChangeConnection(uid: user.uid!, phase: .connected)
                    
                }
            }
        case .rejected:
            
            guard viewModel.hasWeeksPassedSince(forWeeks: 5, timestamp: connection.timestamp) else {
                displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.connectionDeny)
                return
            }
            
            cell.disableButton()
            
            viewModel.connect(withUser: user) { [weak self] error in
                guard let strongSelf = self else { return }
                
                cell.enableButton()
                
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    
                    cell.viewModel?.set(phase: .pending)
                    strongSelf.userDidChangeConnection(uid: user.uid!, phase: .pending)
                }
            }
        case .withdraw:
            
            guard viewModel.hasWeeksPassedSince(forWeeks: 3, timestamp: connection.timestamp) else {
                displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.connection)
                return
            }

            cell.disableButton()
            
            viewModel.connect(withUser: user) { [weak self] error in
                guard let strongSelf = self else { return }
                
                cell.enableButton()
                
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    
                    cell.viewModel?.set(phase: .pending)
                    strongSelf.userDidChangeConnection(uid: user.uid!, phase: .pending)
                }
            }
            
        case .unconnect:
            
            guard viewModel.hasWeeksPassedSince(forWeeks: 5, timestamp: connection.timestamp) else {
                displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.connection5)
                return
            }
            
            cell.disableButton()
            
            viewModel.connect(withUser: user) { [weak self] error in
                guard let strongSelf = self else { return }
                
                cell.enableButton()
                
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    
                    cell.viewModel?.set(phase: .pending)
                    strongSelf.userDidChangeConnection(uid: user.uid!, phase: .pending)
                }
            }
        case .none:
            
            cell.disableButton()
            
            viewModel.connect(withUser: user) { [weak self] error in
                guard let strongSelf = self else { return }
                
                cell.enableButton()

                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    cell.viewModel?.set(phase: .pending)
                    strongSelf.userDidChangeConnection(uid: user.uid!, phase: .pending)
                }
            }
        }
    }
}

extension HomeOnboardingViewController: MESecondaryEmptyCellDelegate {
    func didTapContent(_ content: EmptyContent) {
        navigationController?.popViewController(animated: true)
    }
}

extension HomeOnboardingViewController: UserConnectDelegate {
    
    func userDidChangeConnection(uid: String, phase: ConnectPhase) {
        viewModel.currentNotification = true
        ContentManager.shared.userConnectionChange(uid: uid, phase: phase)
    }
    
    @objc func connectionDidChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? UserConnectionChange {
            if let index = viewModel.users.firstIndex(where: { $0.uid! == change.uid }) {
                viewModel.users[index].editConnectionPhase(phase: change.phase)
                collectionView.reloadData()
            }
        }
    }
}

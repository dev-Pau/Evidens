//
//  FindConnectionsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/3/23.
//

import UIKit
import Firebase

private let whoToFollowReuseIdentifier = "WhoToFollowReuseIdentifier"
private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let emptyUsersCellReuseIdentifier = "EmptyUsersCellReuseIdentifier"

class FindConnectionsViewController: UIViewController {
    
    private var viewModel: FindConnectionsViewModel
  
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureNotificationObservers()
        configureUI()
        fetchUsers()
    }
    
    init(user: User) {
        self.viewModel = FindConnectionsViewModel(user: user)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(connectionDidChange(_:)), name: NSNotification.Name(AppPublishers.Names.connectUser), object: nil)
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ConnectUserCell.self, forCellWithReuseIdentifier: whoToFollowReuseIdentifier)
        collectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyUsersCellReuseIdentifier)
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
    }
    
    private func configureUI() {
        title = AppStrings.Content.Search.people
        view.backgroundColor = .systemBackground
        collectionView.frame = view.bounds
        view.addSubview(collectionView)
    }
    
    private func fetchUsers() {
        viewModel.fetchUsersToConnect { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.reloadData()
            
            if let error, error != .notFound {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    private func getMoreUsers() {
        viewModel.getMoreUsers { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.reloadData()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height {
            getMoreUsers()
        }
    }
}

extension FindConnectionsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.usersLoaded ? viewModel.users.isEmpty ? 1 : viewModel.users.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if viewModel.users.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyUsersCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
            cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Content.User.emptyTitle, description: AppStrings.Content.User.emptyContent, content: .dismiss)
            cell.delegate = self
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: whoToFollowReuseIdentifier, for: indexPath) as! ConnectUserCell
        cell.viewModel = ConnectViewModel(user: viewModel.users[indexPath.row])
        cell.connectionDelegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return viewModel.usersLoaded ? CGSize.zero : CGSize(width: view.frame.width, height: 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.users.isEmpty ? CGSize(width: view.frame.width - 20, height: view.frame.width) : CGSize(width: view.frame.width - 20, height: 63)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = UserProfileViewController(user: viewModel.users[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension FindConnectionsViewController: ConnectUserCellDelegate {
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

extension FindConnectionsViewController: MESecondaryEmptyCellDelegate {
    func didTapContent(_ content: EmptyContent) {
        navigationController?.popViewController(animated: true)
    }
}

extension FindConnectionsViewController: UserConnectDelegate {
    func userDidChangeConnection(uid: String, phase: ConnectPhase) {
        viewModel.currentNotification = false
        ContentManager.shared.userConnectionChange(uid: uid, phase: phase)
    }
    
    @objc func connectionDidChange(_ notificiation: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notificiation.object as? UserConnectionChange {
            if let index = viewModel.users.firstIndex(where: { $0.uid! == change.uid }) {
                viewModel.users[index].editConnectionPhase(phase: change.phase)
                collectionView.reloadData()
            }
        }
    }
}


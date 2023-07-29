//
//  NotificationKindViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/6/23.
//

import UIKit

private let disabledNotificationsCellReuseIdentifier = "DisabledNotificationsCellReuseIdentifier"
private let settingsKindHeaderReuseIdentifier = "SettingsKindHeaderReuseIdentifier"
private let notificationGroupHeaderReuseIdentifier = "NotificationGroupHeaderReuseIdentifier"

private let notificationTargetCellReuseIdentifier = "NotificationTargetCellReuseIdentifier"
private let notificationToggleCellReuseIdentifier = "NotificationToggleCellReuseIdentifier"

private let networkCellReuseIdentifier = "NetworkCellReuseIdentifier"

class NotificationKindViewController: UIViewController {

    var authorization: UNAuthorizationStatus! {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.collectionView.reloadData()
            }
        }
    }
    
    private var collectionView: UICollectionView!
    private var preferences: NotificationPreference?
    private var networkProblem: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPreferences()
        configureNavigationBar()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard let strongSelf = self else { return }
            strongSelf.authorization = settings.authorizationStatus
            
        }
    }
    
    private func fetchPreferences() {
        NotificationService.fetchPreferences { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let preferences):
                strongSelf.preferences = preferences
                strongSelf.collectionView.reloadData()
                strongSelf.collectionView.isHidden = false
            case .failure(let error):
                switch error {
                    
                case .network:
                    strongSelf.networkProblem = true
                    strongSelf.collectionView.reloadData()
                    strongSelf.collectionView.isHidden = false

                case .notFound, .unknown:
                    break
                }
                
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            }
        }
    }
    
    private func configureNavigationBar() {
        title = AppStrings.Settings.notificationsTitle
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)), subitems: [item])
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
            
            let section = NSCollectionLayoutSection(group: group)
            
            if strongSelf.authorization == .authorized {
                section.boundarySupplementaryItems = [header]
            }
            
            return section
        }
        return layout
    }

    private func configure() {
        view.backgroundColor = .systemBackground
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.isHidden = true
        view.addSubviews(collectionView)
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SettingsKindHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: settingsKindHeaderReuseIdentifier)
        collectionView.register(NotificationHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: notificationGroupHeaderReuseIdentifier)
        collectionView.register(DisabledNotificationsCell.self, forCellWithReuseIdentifier: disabledNotificationsCellReuseIdentifier)
        collectionView.register(NotificationTargetCell.self, forCellWithReuseIdentifier: notificationTargetCellReuseIdentifier)
        collectionView.register(NotificationToggleCell.self, forCellWithReuseIdentifier: notificationToggleCellReuseIdentifier)
        collectionView.register(NetworkFailureCell.self, forCellWithReuseIdentifier: networkCellReuseIdentifier)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    @objc func appDidBecomeActive() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard let strongSelf = self else { return }
            strongSelf.authorization = settings.authorizationStatus
            NotificationService.set("enabled", strongSelf.authorization == .authorized ? true : false)
        }
    }
}

extension NotificationKindViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if networkProblem {
            return 1
        } else {
            if authorization == .authorized {
                return NotificationGroup.allCases.count + 1
            } else {
                return 1
            }
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if networkProblem {
            return 1
        } else {
            if authorization == .authorized {
                if section == 0 {
                    return 0
                } else if section == 1 {
                    return NotificationGroup.activity.topic.count
                } else {
                    return NotificationGroup.network.topic.count
                }
            } else {
                return 1
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == 0 {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: settingsKindHeaderReuseIdentifier, for: indexPath) as! SettingsKindHeader
            header.configure(with: SettingKind.notifications.content)
            return header
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: notificationGroupHeaderReuseIdentifier, for: indexPath) as! NotificationHeader
            header.set(title: NotificationGroup.allCases[indexPath.section - 1].title)
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if networkProblem {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkCellReuseIdentifier, for: indexPath) as! NetworkFailureCell
            cell.delegate = self
            return cell
        } else {
            if authorization == .authorized {
                let notification = NotificationTopic.allCases[indexPath.section == 1 ? indexPath.row : indexPath.row + NotificationGroup.activity.topic.count]
                
                switch notification {
                case .replies:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: notificationTargetCellReuseIdentifier, for: indexPath) as! NotificationTargetCell
                    cell.set(title: notification.title)
                    cell.set(onOff: preferences?.reply ?? false)
                    return cell
                case .likes:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: notificationTargetCellReuseIdentifier, for: indexPath) as! NotificationTargetCell
                    cell.set(title: notification.title)
                    cell.set(onOff: preferences?.like ?? false)
                    return cell
                case .followers:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: notificationToggleCellReuseIdentifier, for: indexPath) as! NotificationToggleCell
                    cell.set(title: notification.title)
                    cell.set(isOn: preferences?.follower ?? false)
                    cell.delegate = self
                    return cell
                case .messages:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: notificationToggleCellReuseIdentifier, for: indexPath) as! NotificationToggleCell
                    cell.set(title: notification.title)
                    cell.set(isOn: preferences?.message ?? false)
                    cell.delegate = self
                    return cell
                case .cases:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: notificationToggleCellReuseIdentifier, for: indexPath) as! NotificationToggleCell
                    cell.set(title: notification.title)
                    cell.set(isOn: preferences?.trackCase ?? false)
                    cell.delegate = self
                    return cell
                }
                
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: disabledNotificationsCellReuseIdentifier, for: indexPath) as! DisabledNotificationsCell
                return cell
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard authorization == .authorized, let preferences = preferences, networkProblem == false else { return }
        if indexPath.section == 1 {
            let notification = NotificationTopic.allCases[indexPath.row]

            switch notification {
            case .replies:
                let controller = NotificationTargetViewController(topic: notification, isOn: preferences.reply, target: preferences.replyTarget)
                controller.delegate = self
                navigationController?.pushViewController(controller, animated: true)
            case .likes:
                let controller = NotificationTargetViewController(topic: notification, isOn: preferences.like, target: preferences.likeTarget)
                controller.delegate = self
                navigationController?.pushViewController(controller, animated: true)
            case .followers, .messages, .cases: break
            }
        }
    }
}

extension NotificationKindViewController: NotificationToggleCellDelegate {
    func didToggle(_ cell: UICollectionViewCell, _ value: Bool) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let topic = NotificationTopic.allCases[indexPath.section == 1 ? indexPath.row : indexPath.row + NotificationGroup.activity.topic.count]
            
            switch topic {
            case .replies, .likes: break
            case .followers:
                NotificationService.set("follower", value)
            case .messages:
                NotificationService.set("message", value)
            case .cases:
                NotificationService.set("trackCase", value)
            }
        }
    }
}

extension NotificationKindViewController: NotificationTargetViewControllerDelegate {
    func didChange(topic: NotificationTopic, for target: NotificationTarget) {
        switch topic {
        case .replies:
            preferences?.update(keyPath: \.replyTarget, value: target)
        case .likes:
            preferences?.update(keyPath: \.likeTarget, value: target)
        case .followers, .messages, .cases: break
        }
        
        collectionView.reloadData()
    }
    
    func didToggle(topic: NotificationTopic, _ value: Bool) {
        switch topic {
        case .replies:
            preferences?.update(keyPath: \.reply, value: value)
        case .likes:
            preferences?.update(keyPath: \.like, value: value)
        case .followers, .messages, .cases: break
        }
        
        collectionView.reloadData()
    }
}

extension NotificationKindViewController: NetworkFailureCellDelegate {
    func didTapRefresh() {
        networkProblem = false
        fetchPreferences()
    }
    
    
}

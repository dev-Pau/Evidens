//
//  ContainerViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/9/22.
//

import UIKit

class ContainerViewController: UIViewController {
    
    private var scrollView: UIScrollView!
    
    var baseLogoView: BaseLogoView!
    private var loadingView: Bool?
    
    private let padding: CGFloat = UIDevice.isPad ? 150 : 35
    private var menuWidth: CGFloat!
    
    lazy var menuController = SideMenuViewController()
    let mainController = MainViewController()
    lazy var sideTabController = SideTabViewController()
    
    private lazy var baseView: UIView = {
        let view = UIView()
        view.backgroundColor = K.Colors.separatorColor.withAlphaComponent(0)
        view.isUserInteractionEnabled = false
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissMenu)))
        return view
    }()
    
    init(withLoadingView loadingView: Bool? = nil) {
        if let loadingView {
            self.loadingView = loadingView
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addChildVCs()
    }
    
    private func addChildVCs() {
        menuWidth = UIWindow.visibleScreenWidth - 10 - padding
        
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.delegate = self
        
        addChild(mainController)
        mainController.delegate = self
        mainController.view.translatesAutoresizingMaskIntoConstraints = false
        mainController.didMove(toParent: self)
        mainController.view.addSubview(baseView)
        
        if UIDevice.isPad {
            addChild(sideTabController)
            sideTabController.didMove(toParent: self)
            sideTabController.view.translatesAutoresizingMaskIntoConstraints = false
            sideTabController.popoverDelegate = self

            view.addSubviews(sideTabController.view, mainController.view)

            NSLayoutConstraint.activate([
            
                sideTabController.view.topAnchor.constraint(equalTo: view.topAnchor),
                sideTabController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                sideTabController.view.widthAnchor.constraint(equalToConstant: UIWindow.visibleScreenWidth * 0.13),
                sideTabController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                
                mainController.view.topAnchor.constraint(equalTo: view.topAnchor),
                mainController.view.leadingAnchor.constraint(equalTo: sideTabController.view.trailingAnchor),
                mainController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                mainController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])

            sideTabController.tabDelegate = mainController.mainController
        } else {
            addChild(menuController)

            menuController.delegate = self
            menuController.view.translatesAutoresizingMaskIntoConstraints = false
            menuController.didMove(toParent: self)
            
            view.addSubview(scrollView)
            scrollView.addSubviews(menuController.view, mainController.view)

            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: view.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.widthAnchor.constraint(equalToConstant: view.frame.width),
                scrollView.heightAnchor.constraint(equalToConstant: view.frame.height),
                
                menuController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
                menuController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                menuController.view.widthAnchor.constraint(equalToConstant: menuWidth),
                menuController.view.heightAnchor.constraint(equalToConstant: view.frame.height),
                
                mainController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
                mainController.view.leadingAnchor.constraint(equalTo: menuController.view.trailingAnchor),
                mainController.view.widthAnchor.constraint(equalToConstant: view.frame.width),
                mainController.view.heightAnchor.constraint(equalToConstant: view.frame.height)
            ])
            
            scrollView.setContentOffset(CGPoint(x: menuWidth, y: 0), animated: false)
            scrollView.contentSize.width = view.frame.width + menuWidth
        }
        
        baseView.frame = mainController.view.bounds
        
        if let _ = loadingView {
            baseLogoView = BaseLogoView(frame: view.bounds)
            baseLogoView.backgroundColor = K.Colors.primaryColor
            view.addSubview(baseLogoView)
        }
    }
    
    @objc func dismissMenu() {
        scrollView.setContentOffset(CGPoint(x: menuWidth, y: 0), animated: true)
    }
}

extension ContainerViewController: MainViewControllerDelegate {
    func toggleScroll(_ enabled: Bool) {
        scrollView.isScrollEnabled = enabled
    }
    
    func handleUserIconTap() {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func controllersLoaded() {
        let auth = UserDefaults.getAuth()
        
        if let _ = loadingView {
            
            baseLogoView.removeFromSuperview()
            loadingView = nil
            
            if !auth {
                logout()
                let controller = OpeningViewController()
                let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate
                sceneDelegate?.updateRootViewController(controller)
                return
            }
        }
        
        if let uid = UserDefaults.getUid() {
            DataService.shared.initialize(userId: uid)
            getNewNotificationCount()
        }
        
        scrollView.isScrollEnabled = true
    }
    
    func configureMenuWithUser(user: User) {
        if UIDevice.isPad {
            sideTabController.updateUser(user: user)
        } else {
            menuController.updateUserData(user: user)
        }
    }
    
    func updateUser(user: User) {
        if UIDevice.isPad {
            sideTabController.updateUser(user: user)
        } else {
            menuController.updateUserData()
        }
    }
    
    private func getNewNotificationCount() {
        let date = DataService.shared.getLastNotificationDate()
        
        NotificationService.fetchNewNotificationCount(since: date) { [weak self] results in
            guard let _ = self else { return }
            
            switch results {
                
            case .success(let notifications):
                NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.refreshUnreadNotifications), object: nil, userInfo: ["notifications": notifications])
            case .failure(_):
                NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.refreshUnreadNotifications), object: nil, userInfo: ["notifications": 0])
            }
        }
    }
}

extension ContainerViewController: SideMenuViewControllerDelegate {
    
    func didSelectSubMenuOption(option: SideSubMenuKind) {
        scrollView.setContentOffset(CGPoint(x: menuWidth, y: 0), animated: true)
        mainController.updateUserProfileImageViewAlpha(withAlfa: 1)
        mainController.pushSubMenuOptionController(option: option)
    }
    
    func didSelectMenuOption(option: SideMenu) {
        scrollView.setContentOffset(CGPoint(x: menuWidth, y: 0), animated: true)
        mainController.updateUserProfileImageViewAlpha(withAlfa: 1)
        mainController.pushMenuOptionController(option: option)
    }
    
    func didTapMenuHeader() {
        scrollView.setContentOffset(CGPoint(x: menuWidth, y: 0), animated: true)
        mainController.updateUserProfileImageViewAlpha(withAlfa: 1)
        mainController.pushUserProfileViewController()
    }
}


extension ContainerViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        
        if scrollView == self.scrollView {
            let normalizedOffsetX = max(0.0, min(1.0, 1 - (offsetX / menuWidth)))
            
            let baseAlpha = 0.3 * normalizedOffsetX
            let imageAlpha = 1 - normalizedOffsetX
            
            baseView.backgroundColor = K.Colors.separatorColor.withAlphaComponent(baseAlpha)
            mainController.updateUserProfileImageViewAlpha(withAlfa: imageAlpha)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.x == menuWidth {
            baseView.isUserInteractionEnabled = false
        } else {
            baseView.isUserInteractionEnabled = true
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == menuWidth {
            baseView.isUserInteractionEnabled = false
        } else {
            baseView.isUserInteractionEnabled = true
        }
    }
}

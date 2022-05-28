//
//  ContainerViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/5/22.
//

import UIKit

class ContainerViewController: UIViewController {

    
    //MARK: - Properties
    
    // Width of the side menu
    private let menuWidth : CGFloat = 300
    
    var centerViewLeadingConstraint: NSLayoutConstraint!
    
    private var homeController: UINavigationController!
    
    private let centerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let sideView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        return view
    }()
    
    
    var user: User? {
        didSet {
            configureViews()
            
        }
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        view.addGestureRecognizer(panGesture)
    }
    
    //MARK: - Helpers
    
    func configureViews() {
        view.addSubview(centerView)
        NSLayoutConstraint.activate([
            centerView.topAnchor.constraint(equalTo: view.topAnchor),
            centerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            centerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            centerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        self.centerViewLeadingConstraint = centerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0)
        centerViewLeadingConstraint.isActive = true
        
        view.addSubview(sideView)
        NSLayoutConstraint.activate([
            sideView.topAnchor.constraint(equalTo: view.topAnchor),
            sideView.trailingAnchor.constraint(equalTo: centerView.leadingAnchor),
            sideView.widthAnchor.constraint(equalToConstant: menuWidth),
            sideView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        configureHomeViewController()
        configureMenuViewController()
    }
    
    func configureHomeViewController() {
        guard homeController == nil else { return }
        guard let user = user else { return }
        let home = HomeViewController(collectionViewLayout: UICollectionViewFlowLayout())
        home.user = user
        homeController = UINavigationController(rootViewController: home)
        
        let homeView = homeController.view!
        
        homeView.translatesAutoresizingMaskIntoConstraints = false
        
        centerView.addSubview(homeView)
        NSLayoutConstraint.activate([
            homeView.topAnchor.constraint(equalTo: centerView.topAnchor),
            homeView.trailingAnchor.constraint(equalTo: centerView.trailingAnchor),
            homeView.bottomAnchor.constraint(equalTo: centerView.bottomAnchor),
            homeView.leadingAnchor.constraint(equalTo: centerView.leadingAnchor)
        ])
        
        addChild(homeController)
    }
    
    func configureMenuViewController() {
        
        let menuController = MenuViewController()
        
        let menuView = menuController.view!
        
        menuView.translatesAutoresizingMaskIntoConstraints = false
        
        sideView.addSubview(menuView)
        NSLayoutConstraint.activate([
            menuView.topAnchor.constraint(equalTo: sideView.topAnchor),
            menuView.trailingAnchor.constraint(equalTo: sideView.trailingAnchor),
            menuView.bottomAnchor.constraint(equalTo: sideView.bottomAnchor),
            menuView.leadingAnchor.constraint(equalTo: sideView.leadingAnchor)
        ])
        
        addChild(menuController)
    }
     
    
    //MARK: - Actions
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let x = translation.x
        print(x)
        // Change the constant according to UIPanGestureRecognizer
        centerViewLeadingConstraint.constant = x
        
    }
    
    //MARK: - API
}

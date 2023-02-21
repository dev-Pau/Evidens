//
//  JobsBrowserViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/2/23.
//

import UIKit

class JobsBrowserViewController: UIViewController {
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 200)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
    }
    
    private func configureNavigationBar() {
        title = "Jobs"
        
        guard let tab = self.tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        let jobAction = UIAction(title: "Post a job", image: UIImage(systemName: "bag", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)) { action in
            
            let controller = CreateJobViewController(user: user)
            
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen

            self.present(navVC, animated: true)
        }
        
        let companyAction = UIAction(title: "Add your company", image: UIImage(systemName: "building", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)) { action in
            let controller = CreateCompanyViewController(user: user)
            controller.isControllerPresented = true
            
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen

            self.present(navVC, animated: true)
        }
        
        let manageJobs = UIAction(title: "Manage job posts", image: UIImage(systemName: "tray.and.arrow.down", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)) { action in

        }
        
        let myJobs = UIAction(title: "My jobs", image: UIImage(systemName: "book", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)) { action in

        }
        
        let menuBarButton = UIBarButtonItem(image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), primaryAction: nil, menu: UIMenu(title: "", children: [jobAction, companyAction]))
        let ellipsisButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), primaryAction: nil, menu: UIMenu(title: "", children: [manageJobs, myJobs]))
        navigationItem.rightBarButtonItems = [ellipsisButton, menuBarButton]
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
    }

    @objc func didTapBookmarkJobs() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
                                              
}

extension JobsBrowserViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        <#code#>
    }
}

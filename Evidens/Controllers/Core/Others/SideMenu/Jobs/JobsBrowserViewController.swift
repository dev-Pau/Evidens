//
//  JobsBrowserViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/2/23.
//

import UIKit

class JobsBrowserViewController: UIViewController {
    
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
        
        let menuBarButton = UIBarButtonItem(image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), primaryAction: nil, menu: UIMenu(title: "", children: [jobAction, companyAction]))
        navigationItem.rightBarButtonItem = menuBarButton
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
    }

    @objc func didTapBookmarkJobs() {
        
    }
                                              
}

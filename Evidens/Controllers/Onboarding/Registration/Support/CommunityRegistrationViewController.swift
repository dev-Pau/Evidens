//
//  CommunityRegistrationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/7/22.
//

import UIKit

class CommunityRegistrationViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
    }
    
    private func configureNavigationBar() {
        title = "Community information"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.leftBarButtonItem?.tintColor = blackColor
    }
    
    private func configureUI() {
        view.backgroundColor = .white
    }
    
    @objc func handleCancel() {
        dismiss(animated: true)
    }
}

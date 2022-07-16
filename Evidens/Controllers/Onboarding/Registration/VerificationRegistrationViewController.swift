//
//  VerificationRegistrationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/7/22.
//

import UIKit

class VerificationRegistrationViewController: UIViewController {
    
    private var user: User
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = "Verification"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "questionmark.circle.fill"), style: .done, target: self, action: #selector(handleHelp))
        navigationItem.rightBarButtonItem?.tintColor = grayColor
        
    }
    
    private func configureUI() {
        view.backgroundColor = .white
    }
    
    @objc func handleHelp() {
        
    }
    
}

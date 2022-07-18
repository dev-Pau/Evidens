//
//  PollConfiguratorViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/7/22.
//

import UIKit

class PollConfigurationViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
    }
    
    private func configureNavigationBar() {
        title = "Create a poll"
        
    }
    
    private func configureUI() {
        view.backgroundColor = .systemGreen
    }
}

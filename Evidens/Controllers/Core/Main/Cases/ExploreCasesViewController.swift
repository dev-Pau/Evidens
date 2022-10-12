//
//  ExploreCasesViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/10/22.
//

import UIKit

class ExploreCasesViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
    }
    
    private func configureNavigationBar() {
        title = "Explore"
    }
    
    private func configureUI() {
        view.backgroundColor = .white
    }
}

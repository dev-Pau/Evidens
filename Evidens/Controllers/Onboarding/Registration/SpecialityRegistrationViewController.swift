//
//  SpecialityRegistrationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/7/22.
//

import UIKit

class SpecialityRegistrationViewController: UIViewController {
    
    private let category: User.UserCategory
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    init(category: User.UserCategory) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

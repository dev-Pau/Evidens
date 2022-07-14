//
//  SpecialityRegistrationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/7/22.
//

import UIKit

class SpecialityRegistrationViewController: UIViewController {
    
    private let user: User
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(user.category.userCategoryString)
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

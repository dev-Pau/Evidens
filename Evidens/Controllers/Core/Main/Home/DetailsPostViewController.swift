//
//  DetailsPostViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/7/22.
//

import UIKit

class DetailsPostViewController: UICollectionViewController {
    
    let post: Post
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        view.backgroundColor = lightColor

    }
}

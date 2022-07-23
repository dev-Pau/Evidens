//
//  DetailsPostViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/7/22.
//

import UIKit

class DetailsPostViewController: UIViewController {
    
    let post: Post
    let height: CGFloat
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    init(post: Post, height: CGFloat) {
        self.post = post
        self.height = height
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        view.backgroundColor = lightColor
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        
        let homeVC = HomeViewController(collectionViewLayout: layout)
        homeVC.collectionView.isScrollEnabled = false
        homeVC.post = post
        addChild(homeVC)
        view.addSubview(homeVC.view)
        homeVC.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: height + 120)
        homeVC.didMove(toParent: self)
    }
}

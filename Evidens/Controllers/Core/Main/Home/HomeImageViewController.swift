//
//  HomeImageViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/7/22.
//

import UIKit

class HomeImageViewController: UIViewController {
    
    private var postImage: UIImage!
    private var height: CGFloat!
    
    private var zoomTransitioning = ZoomTransitioning()
    
    let scrollableImageView = MEScrollImageView(frame: .zero)
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.isHidden = true
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = searchBar
        navigationController?.delegate = zoomTransitioning
    }
    
    init(image: UIImage, height: CGFloat) {
        super.init(nibName: nil, bundle: nil)
        self.postImage = image
        self.height = height
        configure()
    }
     
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.tabBarController?.tabBar.isHidden = false
    }

    private func configure() {
        scrollableImageView.frame = view.bounds
        view.addSubview(scrollableImageView)
        scrollableImageView.display(image: postImage)
    }
}

extension HomeImageViewController: ZoomTransitioningDelegate {
    func zoomingImageView(for transition: ZoomTransitioning) -> UIImageView? {
        return scrollableImageView.zoomImageView
    }
}





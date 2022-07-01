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
    
    let postImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
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
        view.addSubview(postImageView)
        postImageView.image = postImage
        
        
        NSLayoutConstraint.activate([
            postImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            postImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            postImageView.heightAnchor.constraint(equalToConstant: height),
            postImageView.widthAnchor.constraint(equalToConstant: view.frame.width),
        ])
    }
}

extension HomeImageViewController: ZoomTransitioningDelegate {
    func zoomingImageView(for transition: ZoomTransitioning) -> UIImageView? {
        return postImageView
    }
}



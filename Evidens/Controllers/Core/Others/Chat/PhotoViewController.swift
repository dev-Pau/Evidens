//
//  PhotoViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/2/22.
//

import UIKit
import SDWebImage

class PhotoViewController: UIViewController {
    
    private let url: URL
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        imageView.frame = view.bounds
        imageView.sd_setImage(with: url, completed: nil)
        
        scrollView.maximumZoomScale = 4
        scrollView.minimumZoomScale = 1
        
        scrollView.clipsToBounds = false
        //scrollView.delegate = self
    }
    
    @objc func dismissConversation() {
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        scrollView.contentSize = imageView.bounds.size
        scrollView.addSubview(imageView)
        view.addSubview(scrollView)
    }
    
    init(with url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - UIScrollViewDelegate
extension PhotoViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}


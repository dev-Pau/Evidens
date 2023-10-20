//
//  ViewController.swift
//  ScrollViewTolbar
//
//  Created by Pau Fernández Solà on 20/10/23.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {

    var scrollView: UIScrollView!
    var collectionView: UICollectionView!
    var iv: UIImageView!
    var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configure()
    }
    
    var headView: UIView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(iv.frame.height)
        //configure()
        
        NSLayoutConstraint.activate([
            
            headView.topAnchor.constraint(equalTo: iv.topAnchor),
            headView.heightAnchor.constraint(equalToConstant: iv.frame.height * 0.18),
            headView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func configure() {
        title = "ScrollView"
        iv = UIImageView()
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "body")?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        
        headView = UIView()
        headView.layer.borderColor = UIColor.label.cgColor
        headView.layer.borderWidth = 2
        headView.translatesAutoresizingMaskIntoConstraints = false
        headView.backgroundColor = .clear
      
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.addSubview(iv)
        scrollView.addSubview(headView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .systemBackground
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.delegate = self
        
        bottomConstraint = iv.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        bottomConstraint.isActive = true
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.widthAnchor.constraint(equalToConstant: view.frame.width),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            iv.topAnchor.constraint(equalTo: scrollView.topAnchor),
            iv.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            iv.trailingAnchor.constraint(equalTo: view.trailingAnchor),
         
        ])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print(scrollView.contentOffset.y)
        let y = scrollView.contentOffset.y
        bottomConstraint.constant = -y



    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "id", for: indexPath)
        cell.backgroundColor = indexPath.row % 2 == 0 ? .systemPink : .systemGreen
        return cell
    }
}

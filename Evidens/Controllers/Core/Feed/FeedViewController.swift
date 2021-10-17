//
//  FeedController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/21.
//

import UIKit

private let reuseIdentifier = "Cell"

class FeedViewController: UICollectionViewController {
    
    //MARK: - Properties
    var feedDelegate: FeedViewControllerDelegate?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNavigationItemButtons()        
    }
    
    //MARK: - Helpers
    func configureUI() {
        collectionView.backgroundColor = .white
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    func configureNavigationItemButtons() {
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: .init(systemName: "checklist"), style: .plain, target: self, action: #selector(didTapFilter)), UIBarButtonItem(image: .init(systemName: "paperplane"), style: .plain, target: self, action: #selector(didTapChat))]
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .init(systemName: "person.fill"), style: .plain, target: self, action: #selector(didTapProfile))
        navigationItem.leftBarButtonItem?.tintColor = .black
        navigationItem.rightBarButtonItems?[0].tintColor = .black
        navigationItem.rightBarButtonItems?[1].tintColor = .black
    }
    
    //MARK: - Actions
    @objc func didTapProfile() {
        feedDelegate?.handleMenuToggle()
    }
    
    @objc func didTapFilter() {
        print("DEBUG: did tap filter")
    }
                                              
    @objc func didTapChat() {
        print("DEBUG: did tap chat")
        }
                
    //Manage ScrollView animation
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let magicalSafeAreaTop = topbarHeight
        let offset = scrollView.contentOffset.y + magicalSafeAreaTop
        navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, -offset))
    }
}

//MARK: - UICollectionViewDataSource

extension FeedViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
        cell.layer.borderWidth = 0.19
        cell.layer.borderColor = UIColor.lightGray.cgColor
        return cell
    }
}


//MARK: - UICollectionViewDelegateFlowLayout

extension FeedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 180)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
          return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 0.0
        }
    
}

extension FeedViewController {
    //Get height of status bar + navigation bar
    var topbarHeight: CGFloat {
        return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
}

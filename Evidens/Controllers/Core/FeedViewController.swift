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
        configureBlurryTopView()
        configureNavigationItemButtons()
        fetchPosts()
    }
    
    
    
    //MARK: - Helpers
    func configureUI() {
        collectionView.backgroundColor = .white
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    func configureBlurryTopView() {
        let statusBarView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        view.addSubview(statusBarView)
        statusBarView.backgroundColor = UIColor(white: 1, alpha: 1)

    }
    
    func configureNavigationItemButtons() {
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: .init(systemName: "checklist"), style: .plain, target: self, action: #selector(didTapFilter)), UIBarButtonItem(image: .init(systemName: "envelope"), style: .plain, target: self, action: #selector(didTapChat)), UIBarButtonItem(image: .init(systemName: "plus.app"), style: .plain, target: self, action: #selector(didTapPost))]
        navigationItem.rightBarButtonItems?[0].tintColor = .black
        navigationItem.rightBarButtonItems?[1].tintColor = .black
        navigationItem.rightBarButtonItems?[2].tintColor = .black
    }
    
    //MARK: - Actions

    @objc func didTapFilter() {
        print("DEBUG: did tap filter")
    }
                                              
    @objc func didTapChat() {
        print("DEBUG: did tap chat")
        }
    
    @objc func didTapPost() {
        let controller = UploadPostViewController()
        controller.hidesBottomBarWhenPushed = true
        //navigationController?.pushViewController(controller, animated: false)
        navigationController?.pushViewController(controller, animated: true)
        
    }
                
    //Manage ScrollView animation
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let magicalSafeAreaTop = topbarHeight
        let offset = scrollView.contentOffset.y + magicalSafeAreaTop
        
        let alpha: CGFloat = 1 - ((scrollView.contentOffset.y + magicalSafeAreaTop) / magicalSafeAreaTop)
        navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, -offset))

        navigationItem.rightBarButtonItems?[0].tintColor = .black.withAlphaComponent(alpha)
        navigationItem.rightBarButtonItems?[1].tintColor = .black.withAlphaComponent(alpha)
        navigationItem.rightBarButtonItems?[2].tintColor = .black.withAlphaComponent(alpha)
        
        
    }
    
    //MARK: - API
    
    func fetchPosts() {
        PostService.fetchPosts()
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


//
//  NewsListViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/3/23.
//

import UIKit
import Firebase

private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let recentsCellReuseIdentifier = "RecentsCellReuseIdentifier"

class NewsListViewController: UIViewController {
    private var news = [New]()
    private var lastNewSnapshot: QueryDocumentSnapshot?
    private var newsLoaded: Bool = false
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        configureUI()
        fetchNews()
    }
    
    private func configureNavigationBar() {

    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(RecentNewsCell.self, forCellWithReuseIdentifier: recentsCellReuseIdentifier)
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground 
        collectionView.frame = view.bounds
        view.addSubview(collectionView)
    }
    
    private func fetchNews() {
        if title == "Latest News" {
            NewService.fetchNewsForYou(lastSnapshot: nil) { snapshot in
                self.lastNewSnapshot = snapshot.documents.last
                self.news = snapshot.documents.map({ New(dictionary: $0.data()) })
                self.newsLoaded = true
                self.collectionView.reloadData()
            }
        } else {
            NewService.fetchRecentNews(lastSnapshot: nil) { snapshot in
                self.lastNewSnapshot = snapshot.documents.last
                self.news = snapshot.documents.map({ New(dictionary: $0.data()) })
                self.newsLoaded = true
                self.collectionView.reloadData()
            }
        }
    }
}

extension NewsListViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newsLoaded ? news.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: recentsCellReuseIdentifier, for: indexPath) as! RecentNewsCell
        cell.viewModel = NewViewModel(new: news[indexPath.row])
        cell.addSeparatorView()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 20, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return newsLoaded ? CGSize.zero: CGSize(width: view.frame.width, height: 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !news.isEmpty else { return }
        let controller = NewViewController(new: news[indexPath.row])
        controller.topBarHeight = topbarHeight
         navigationController?.pushViewController(controller, animated: true)
    }
}

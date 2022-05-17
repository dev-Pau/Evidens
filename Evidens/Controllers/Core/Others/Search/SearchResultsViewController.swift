//
//  DetailedSearchViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/5/22.
//

import UIKit

private let reuseIdentifier = "CollectionViewCell"

class SearchResultsViewController: UIViewController {
   
    //MARK: - Properties
    public var searchedText = ""
    
    private let searchTopics = ["Top", "People", "Posts", "Cases"]
    
    weak var delegate: CollectionViewDidScrollDelegate?
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        //searchBar.searchTextField.attributedPlaceholder = atrString
        searchBar.searchTextField.backgroundColor = lightColor
        return searchBar
    }()
    
    private lazy var segmentedButtonsView: CustomSegmentedButtonsView = {
        let segmentedButtonsView = CustomSegmentedButtonsView()
        segmentedButtonsView.setLabelsTitles(titles: searchTopics)
        segmentedButtonsView.translatesAutoresizingMaskIntoConstraints = false
        
        segmentedButtonsView.backgroundColor = .white
        return segmentedButtonsView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.scrollDirection = .horizontal
        collectionViewFlowLayout.minimumLineSpacing = 1
        collectionViewFlowLayout.minimumInteritemSpacing = 1
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        collectionView.isPagingEnabled = true
        collectionView.indicatorStyle = .white
        return collectionView
    }()
    
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchBar()
        configureUI()
        configureCollectionView()
    }
    
    //MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white

        view.addSubview(segmentedButtonsView)
        segmentedButtonsView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor)
        segmentedButtonsView.setHeight(40)
        
        view.addSubview(collectionView)
        collectionView.anchor(top: segmentedButtonsView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        collectionView.backgroundColor = .white
    }
    
    func configureSearchBar() {
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        searchBar.text = searchedText
    }
    
    func configureCollectionView() {
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        segmentedButtonsView.segmentedControlDelegate = self
        
    }
    
    
    
    func scrollToFrame(scrollOffset : CGFloat) {
        guard scrollOffset <= collectionView.contentSize.width - collectionView.bounds.size.width else { return }
        guard scrollOffset >= 0 else { return }
        collectionView.setContentOffset(CGPoint(x: scrollOffset, y: collectionView.contentOffset.y), animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate = segmentedButtonsView
        delegate?.collectionViewDidScroll(for: scrollView.contentOffset.x / 4)
    }
}



//MARK: - UICollectionViewDataSource

extension SearchResultsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchTopics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        cell.backgroundColor = lightGrayColor
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.view.frame.height - 150)
    }
    
    
}

extension SearchResultsViewController: UICollectionViewDelegateFlowLayout {
    
}

extension SearchResultsViewController: UICollectionViewDelegate {
}


//MARK: - UISearchBarDelegate

extension SearchResultsViewController: UISearchBarDelegate {
    
}

//MARK: - SegmentedControlDelegate

extension SearchResultsViewController: SegmentedControlDelegate {
    func indexDidChange(from currentIndex: Int, to index: Int) {
        let collectionBounds = self.collectionView.bounds
        // Switch based on the current index of the CustomSegmentedButtonsView
        switch currentIndex {
        case 0:
            if (index == 1) {
                // Wants to move to second index
                let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x + collectionBounds.size.width))
                self.moveToFrame(contentOffset: contentOffset)
            } else if index == 2 {
                // Wants to move to third index
                let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x + collectionBounds.size.width * 2))
                self.moveToFrame(contentOffset: contentOffset)
            } else if (index == 3) {
                let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x + collectionBounds.size.width * 3))
                self.moveToFrame(contentOffset: contentOffset)
            }
        case 1:
            if (index == 0) {
                // Wants to move to first index
                let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x - collectionBounds.size.width))
                self.moveToFrame(contentOffset: contentOffset)
            } else if (index == 2) {
                let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x + collectionBounds.size.width))
                self.moveToFrame(contentOffset: contentOffset)
            } else if (index == 3) {
                let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x + collectionBounds.size.width * 2))
                self.moveToFrame(contentOffset: contentOffset)
            }
        case 2:
            if (index == 0) {
                let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x - collectionBounds.size.width * 2))
                self.moveToFrame(contentOffset: contentOffset)
            } else if (index == 1) {
                let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x - collectionBounds.size.width))
                self.moveToFrame(contentOffset: contentOffset)
            } else if (index == 3) {
                let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x + collectionBounds.size.width))
                self.moveToFrame(contentOffset: contentOffset)
            }
        case 3:
            if (index == 0) {
                let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x - collectionBounds.size.width * 3))
                self.moveToFrame(contentOffset: contentOffset)
            } else if (index == 1) {
                let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x - collectionBounds.size.width * 2))
                self.moveToFrame(contentOffset: contentOffset)
            } else if (index == 2){
                let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x - collectionBounds.size.width * 1))
                self.moveToFrame(contentOffset: contentOffset)
            }
        default:
            print("error")
        }
    }
    
    func moveToFrame(contentOffset : CGFloat) {
        let frame: CGRect = CGRect(x : contentOffset ,y : self.collectionView.contentOffset.y ,width : self.collectionView.frame.width, height: self.collectionView.frame.height)
        self.collectionView.scrollRectToVisible(frame, animated: true)
    }
}

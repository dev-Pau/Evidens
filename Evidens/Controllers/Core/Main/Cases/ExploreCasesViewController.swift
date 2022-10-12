//
//  ExploreCasesViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/10/22.
//

import UIKit

private let exploreReuseIdentifier = "ExploreReuseIdentifier"

class ExploreCasesViewController: UIViewController {
    
    private var categoriesCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionViews()
        configureUI()
        
    }
    
    private func configureNavigationBar() {
        title = "Explore"
    }
    
    private func configureUI() {
        view.backgroundColor = .white
    }
    
    private func configureCollectionViews() {
        categoriesCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createExploreLayout())
        categoriesCollectionView.register(CategoriesExploreCasesCell.self, forCellWithReuseIdentifier: exploreReuseIdentifier)
        categoriesCollectionView.delegate = self
        categoriesCollectionView.dataSource = self
        view.addSubview(categoriesCollectionView)
        
    
    }
    
    private func createExploreLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in

            let doubleItem = NSCollectionLayoutItem(

                            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                               heightDimension: .fractionalHeight(1.0)))
            doubleItem.contentInsets.trailing = 10
            doubleItem.contentInsets.bottom = 10

            let doubleVerticalGroup = NSCollectionLayoutGroup.vertical(

                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.15),
                                                               heightDimension: .fractionalHeight(1.0)),
                            subitem: doubleItem, count: 3)
            
            
            let repeatingGroup = NSCollectionLayoutGroup.horizontal(
                          
                            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(2),
                                                               heightDimension: .absolute(320)),
                            subitems: [doubleVerticalGroup])
            
            repeatingGroup.contentInsets.leading = 10
            repeatingGroup.contentInsets.top = 10

                        let section = NSCollectionLayoutSection(group: repeatingGroup)
            section.orthogonalScrollingBehavior = .continuous

            return section
        }
        return layout
    }
}

extension ExploreCasesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 13
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: exploreReuseIdentifier, for: indexPath) as! CategoriesExploreCasesCell
        return cell
    }
}

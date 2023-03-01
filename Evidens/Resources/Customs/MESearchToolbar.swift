//
//  MESearchToolbar.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/2/23.
//

import UIKit

private let filterCellReuseIdentifier = "FilterCellReuseIdentifier"
private let professionSelectedCellReuseIdentifier = "ProfessionSelectedCellReuseIdentifier"

protocol MESearchToolbarDelegate: AnyObject {
    func didSelectSearchCategory(_ category: String)
}

class MESearchToolbar: UIToolbar {
    weak var searchDelegate: MESearchToolbarDelegate?
    private var collectionView: UICollectionView!
    private let dataSource = Profession.getAllProfessions().map({ $0.profession })
    private var displayDataSource = [String]()
    private let searchDataSource = ["People", "Posts", "Cases", "Groups", "Jobs"]
    private var isInSearchMode: Bool = false
    private var searchingWithCategorySelected: Bool = false
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .quaternarySystemFill
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        displayDataSource = dataSource
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCellLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(FilterCasesCell.self, forCellWithReuseIdentifier: filterCellReuseIdentifier)
        collectionView.register(ProfessionSelectedCell.self, forCellWithReuseIdentifier: professionSelectedCellReuseIdentifier)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: "kek")
        addSubviews(collectionView, separatorView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    private func createCellLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            let headerSize = NSCollectionLayoutSize(widthDimension: .absolute(50), heightDimension: .absolute(30))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .leading)
            //header.pinToVisibleBounds = true
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .estimated(200), heightDimension: .fractionalHeight(1)))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .estimated(200), heightDimension: .absolute(30)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
         
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
            section.interGroupSpacing = 10
            
          //  if self.isInSearchMode {
            //    section.boundarySupplementaryItems = [header]
                
           // }

            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10)
            return section
        }
        
        return layout
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.x)
    }
}

extension MESearchToolbar: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "kek", for: indexPath)
        header.backgroundColor = .systemPink
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isInSearchMode && indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: professionSelectedCellReuseIdentifier, for: indexPath) as! ProfessionSelectedCell
            cell.tagsLabel.text = displayDataSource[indexPath.row]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: filterCellReuseIdentifier, for: indexPath) as! FilterCasesCell
            cell.tagsLabel.text = displayDataSource[indexPath.row]
            //if isInSearchMode { collectionView.selectItem(at: IndexPath(item: 1, section: 0), animated: false, scrollPosition: .left) }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isInSearchMode {
            let valueSelected = displayDataSource[indexPath.row]
            collectionView.performBatchUpdates {
                collectionView.moveItem(at: indexPath, to: IndexPath(item: 1, section: 0))
            } completion: { _ in
                self.displayDataSource = [self.displayDataSource[0], self.displayDataSource[1]]
                self.collectionView.deleteItems(at: [IndexPath(item: 2, section: 0), IndexPath(item: 3, section: 0), IndexPath(item: 4, section: 0), IndexPath(item: 5, section: 0)])
                self.searchingWithCategorySelected = true
            }
         
            //collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        } else {
            UIView.animate(withDuration: 0.2) {
                collectionView.frame.origin.y = -50
                self.separatorView.backgroundColor = .systemBackground
            } completion: { _ in
                self.displayDataSource = self.searchDataSource
                self.displayDataSource.insert("   \(self.dataSource[indexPath.row])", at: 0)

                self.isInSearchMode = true
                self.collectionView.reloadData()
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseIn) {
                    collectionView.frame.origin.y = 0
                    self.separatorView.backgroundColor = .quaternarySystemFill
                }
            }
            searchDelegate?.didSelectSearchCategory(dataSource[indexPath.row])
        }
        //collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if isInSearchMode && indexPath.row == 0 || searchingWithCategorySelected { return false }
        return true
    }
}

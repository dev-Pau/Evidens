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
    func didRestoreMenu()
    func didSelectSearchTopic(_ topic: String)
    func didSelectSearchCategory(_ category: Search.Topics)
}

class MESearchToolbar: UIToolbar {
    weak var searchDelegate: MESearchToolbarDelegate?
    private var collectionView: UICollectionView!
    private let dataSource = Profession.getAllProfessions().map({ $0.profession })
    private var displayDataSource = [String]()
    private let searchDataSource = Search.Topics.allCases
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
        //setBackgroundImage(UIImage(), forToolbarPosition: .topAttached, barMetrics: .default)
        barTintColor = UIColor.systemBackground
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
             if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                 // ColorUtils.loadCGColorFromAsset returns cgcolor for color name
                 barTintColor = UIColor.systemBackground
             }
         }
    }
    
    private func createCellLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            let headerSize = NSCollectionLayoutSize(widthDimension: .absolute(50), heightDimension: .absolute(30))

            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .estimated(200), heightDimension: .fractionalHeight(1)))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .estimated(200), heightDimension: .absolute(30)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
         
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
            section.interGroupSpacing = 5
            

            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10)
            return section
        }
        
        return layout
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
            cell.setText(text: displayDataSource[indexPath.row])
            cell.selectedTag = displayDataSource[indexPath.row]
            if searchingWithCategorySelected { cell.selectedCategory = displayDataSource[indexPath.row + 1] } else {
                cell.selectedCategory = nil
            }
            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: filterCellReuseIdentifier, for: indexPath) as! FilterCasesCell
            //cell.tagsLabel.text = displayDataSource[indexPath.row]
            cell.setText(text: displayDataSource[indexPath.row])
            //if isInSearchMode { collectionView.selectItem(at: IndexPath(item: 1, section: 0), animated: false, scrollPosition: .left) }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isInSearchMode {
            //let valueSelected = displayDataSource[indexPath.row]
            collectionView.performBatchUpdates {
                collectionView.moveItem(at: indexPath, to: IndexPath(item: 1, section: 0))
            } completion: { _ in
                self.displayDataSource = [self.displayDataSource[0], self.displayDataSource[indexPath.row]]
                self.collectionView.deleteItems(at: [IndexPath(item: 2, section: 0), IndexPath(item: 3, section: 0), IndexPath(item: 4, section: 0), IndexPath(item: 5, section: 0)])
                self.searchingWithCategorySelected = true
                self.collectionView.reloadItems(at: [IndexPath(item: 0, section: 0)])
                self.searchDelegate?.didSelectSearchCategory(self.searchDataSource[indexPath.row - 1])
            }

        } else {
            UIView.animate(withDuration: 0.2) {
                collectionView.frame.origin.y = -50
                self.separatorView.backgroundColor = .systemBackground
            } completion: { _ in
                self.displayDataSource = [String]()
                self.displayDataSource.append(self.dataSource[indexPath.row])
                self.displayDataSource.append(contentsOf: self.searchDataSource.map({ $0.rawValue }))

                self.isInSearchMode = true
                self.collectionView.reloadData()
                self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseIn) {
                    collectionView.frame.origin.y = 0
                    self.separatorView.backgroundColor = .quaternarySystemFill
                }
            }
            searchDelegate?.didSelectSearchTopic(dataSource[indexPath.row])
        }
        //collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if isInSearchMode && indexPath.row == 0 || searchingWithCategorySelected { return false }
        return true
    }
}

extension MESearchToolbar: ProfessionSelectedCellDelegate {
    func didSelectSearchTopic(_ topic: String) {
        if displayDataSource[0] == topic { return }
        if searchingWithCategorySelected {
            UIView.animate(withDuration: 0.2) {
                self.collectionView.alpha = 0
            } completion: { _ in
                self.displayDataSource.removeAll()
                self.displayDataSource.append(topic)
                self.displayDataSource.append(contentsOf: self.searchDataSource.map({ $0.rawValue }))
                self.collectionView.reloadData()
                self.searchingWithCategorySelected = false
                
                
                self.searchDelegate?.didSelectSearchTopic(topic)
                
                
                UIView.animate(withDuration: 0.2) {
                    self.collectionView.alpha = 1
                }
            }
        } else {
            displayDataSource[0] = topic
            self.collectionView.reloadItems(at: [IndexPath(item: 0, section: 0)])
            self.collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: [])
            
            searchDelegate?.didSelectSearchTopic(topic)
        }
    }
    
    func didSelectSearchCategory(_ category: Search.Topics) {
        if searchingWithCategorySelected {
            if displayDataSource[1] == category.rawValue { return }
            displayDataSource[1] = category.rawValue
            self.collectionView.reloadItems(at: [IndexPath(item: 1, section: 0)])
            self.collectionView.reloadItems(at: [IndexPath(item: 0, section: 0)])
            
            self.collectionView.selectItem(at: IndexPath(item: 1, section: 0), animated: false, scrollPosition: [])
        } else {
            if let index = displayDataSource.firstIndex(where: { $0 == category.rawValue }) {

                collectionView.performBatchUpdates {
                    self.collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: [])
                    self.collectionView.moveItem(at: IndexPath(item: index, section: 0), to: IndexPath(item: 1, section: 0))
                } completion: { _ in
                    self.displayDataSource = [self.displayDataSource[0], self.displayDataSource[index]]
                    self.collectionView.performBatchUpdates {
                        self.collectionView.deleteItems(at: [IndexPath(item: 2, section: 0), IndexPath(item: 3, section: 0), IndexPath(item: 4, section: 0), IndexPath(item: 5, section: 0)])
                        self.searchingWithCategorySelected = true
                        self.collectionView.reloadItems(at: [IndexPath(item: 0, section: 0)])
                    } completion: { _ in
                        
                    }
                }
            }
        }
        searchDelegate?.didSelectSearchCategory(category)
    }
    
    func didRestoreMenu() {
        UIView.animate(withDuration: 0.2) {
            self.collectionView.alpha = 0
            self.separatorView.backgroundColor = .systemBackground
        } completion: { _ in
            self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
            self.displayDataSource = self.dataSource
            self.isInSearchMode = false
            self.searchingWithCategorySelected = false
            self.collectionView.reloadData()
            self.collectionView.frame.origin.y = -50
            self.collectionView.alpha = 1
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseIn) {
                self.collectionView.frame.origin.y = 0
                self.separatorView.backgroundColor = .quaternarySystemFill
                self.searchDelegate?.didRestoreMenu()
            }
        }
    }
}

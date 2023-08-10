//
//  MESearchToolbar.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/2/23.
//

import UIKit

private let filterCellReuseIdentifier = "FilterCellReuseIdentifier"
private let professionSelectedCellReuseIdentifier = "ProfessionSelectedCellReuseIdentifier"

protocol SearchToolbarDelegate: AnyObject {
    func didRestoreMenu()
    func didSelectDiscipline(_ discipline: Discipline)
    func didSelectSearchCategory(_ category: SearchTopics)
    
    
    func showDisciplinesMenu(withOption option: String)
    func showCategoriesMenu(withCategory category: String)
}

class SearchToolbar: UIToolbar {
    weak var searchDelegate: SearchToolbarDelegate?
    private var collectionView: UICollectionView!
    
    private var discipline: Discipline?
    
    private var searchMode: SearchMode = .discipline
    
    private let dataSource = Discipline.allCases.map { $0.name }

    private var displayDataSource = [String]()
    private let searchDataSource = SearchTopics.allCases
    private var isInSearchMode: Bool = false
    private var searchingWithCategorySelected: Bool = false
    private var separatorColor: UIColor!
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        barTintColor = UIColor.systemBackground
        setBackgroundImage(UIImage(), forToolbarPosition: .bottom, barMetrics: .default)
        setShadowImage(UIImage(), forToolbarPosition: .bottom)
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
        collectionView.register(SearchToolbarCell.self, forCellWithReuseIdentifier: professionSelectedCellReuseIdentifier)
        addSubviews(collectionView, separatorView)
        
        if let tabControllerShadowColor = UITabBarController().tabBar.standardAppearance.shadowColor {
            separatorColor = tabControllerShadowColor
            separatorView.backgroundColor = separatorColor
        }
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4)
        ])
    }
    
    private func createCellLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let _ = self else { return nil }
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .estimated(300), heightDimension: .fractionalHeight(1)))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .estimated(300), heightDimension: .absolute(30)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
         
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 5

            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10)
            return section
        }
        
        return layout
    }
    
    func showToolbar() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseIn) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.frame.origin.y = 0
            strongSelf.separatorView.backgroundColor = strongSelf.separatorColor
        }
    }
}

extension SearchToolbar: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch searchMode {
        case .discipline:
            return Discipline.allCases.count
        case .topic:
            return SearchTopics.allCases.count + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch searchMode {
        case .discipline:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: filterCellReuseIdentifier, for: indexPath) as! FilterCasesCell
            cell.changeAppearanceOnSelection = false
            cell.set(discipline: Discipline.allCases[indexPath.row])
            return cell
        case .topic:
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: professionSelectedCellReuseIdentifier, for: indexPath) as! SearchToolbarCell
                if let discipline {
                    cell.set(discipline: discipline)
                }
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: filterCellReuseIdentifier, for: indexPath) as! FilterCasesCell
                cell.changeAppearanceOnSelection = false
                cell.set(searchTopic: SearchTopics.allCases[indexPath.row - 1])
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch searchMode {
            
        case .discipline:
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let strongSelf = self else { return }
                collectionView.frame.origin.y = -50
                strongSelf.separatorView.backgroundColor = .systemBackground
            } completion: { [weak self] _ in
                guard let strongSelf = self else { return }
                //self.displayDataSource = [String]()
                strongSelf.searchMode = .topic
                strongSelf.discipline = Discipline.allCases[indexPath.row]
                //self.displayDataSource.append(self.dataSource[indexPath.row])
                //self.displayDataSource.append(contentsOf: self.searchDataSource.map({ $0.title }))

                //self.isInSearchMode = true
                strongSelf.collectionView.reloadData()
                strongSelf.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
                strongSelf.searchDelegate?.didSelectDiscipline(Discipline.allCases[indexPath.row])

            }
        case .topic:
            print("is topic")
        }
        
        
        if isInSearchMode {
            print("is in searach mode")
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
            print("is in other mode")
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if isInSearchMode && indexPath.row == 0 || searchingWithCategorySelected {
            if indexPath.row == 0 {
                searchDelegate?.showDisciplinesMenu(withOption: displayDataSource[0])
            } else {
                searchDelegate?.showCategoriesMenu(withCategory: displayDataSource[indexPath.row])
            }
            return false
        }
        return true
    }
}

extension SearchToolbar: SearchToolbarCellDelegate {
    
    func didSelectSearchTopic(_ topic: String) {
        /*
        if displayDataSource[0] == topic { return }
        if searchingWithCategorySelected {
            UIView.animate(withDuration: 0.2) {
                self.collectionView.alpha = 0
            } completion: { _ in
                self.displayDataSource.removeAll()
                self.displayDataSource.append(topic)
                self.displayDataSource.append(contentsOf: self.searchDataSource.map({ $0.title }))
                self.collectionView.reloadData()
                self.searchingWithCategorySelected = false

                self.searchDelegate?.didSelectDiscipline(topic)

                UIView.animate(withDuration: 0.2) {
                    self.collectionView.alpha = 1
                }
            }
        } else {
            displayDataSource[0] = topic
            self.collectionView.reloadItems(at: [IndexPath(item: 0, section: 0)])
            self.collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: [])
            searchDelegate?.didSelectDiscipline(topic)
        }
         */
    }
    
    func didSelectSearchCategory(_ category: SearchTopics) {
        /*
        if searchingWithCategorySelected {
            print("search with category selected")
            if displayDataSource[1] == category.title { return }
            displayDataSource[1] = category.title
            self.collectionView.reloadItems(at: [IndexPath(item: 1, section: 0)])
            self.collectionView.reloadItems(at: [IndexPath(item: 0, section: 0)])
            
            self.collectionView.selectItem(at: IndexPath(item: 1, section: 0), animated: false, scrollPosition: [])
        } else {
            if let index = displayDataSource.firstIndex(where: { $0 == category.title }) {
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
         */
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
                self.separatorView.backgroundColor = self.separatorColor
                self.searchDelegate?.didRestoreMenu()
            }
        }
    }
}

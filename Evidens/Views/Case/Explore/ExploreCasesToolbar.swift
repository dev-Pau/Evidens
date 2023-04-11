//
//  ExploreCasesToolbar.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/1/23.
//

import UIKit

private let separatorCellReuseIdentifier = "SeparatorCellReuseIdentifier"
private let exploreCellReuseIdentifier = "ExploreCellReuseIdentifier"
private let filterCellReuseIdentifier = "FilterCellReuseIdentifier"

protocol ExploreCasesToolbarDelegate: AnyObject {
    func wantsToSeeCategory(category: Case.FilterCategories)
}

class ExploreCasesToolbar: UIToolbar {
    
    private let selectionCellView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = primaryColor
        return view
    }()
    
    private var filterCollectionView: UICollectionView!
    private var indexSelected: Int = 1
    private var didSelectFirstByDefault: Bool = false
    private var cellPoint: CGPoint!
    
    weak var exploreDelegate: ExploreCasesToolbarDelegate?
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createFilterCellLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .estimated(200), heightDimension: .fractionalHeight(1)))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .estimated(200), heightDimension: .fractionalHeight(1)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 10
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)

            section.visibleItemsInvalidationHandler = { (visibleItems, point, env) -> Void in
                self.cellPoint = point
                if let indexPath = self.filterCollectionView.indexPathsForSelectedItems?.first, let cell = self.filterCollectionView.cellForItem(at: indexPath) as? FilterCasesCell {
                    self.selectionCellView.frame.origin.x = cell.frame.origin.x - point.x
                }
            }
            
            return section
        }
        return layout
    }
    
    private func configure() {
        filterCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createFilterCellLayout())
        filterCollectionView.bounces = true
        filterCollectionView.alwaysBounceVertical = false
        filterCollectionView.alwaysBounceHorizontal = true
        filterCollectionView.backgroundColor = .clear
        
        addSubviews(selectionCellView, filterCollectionView)
        NSLayoutConstraint.activate([
            //filterCollectionView.topAnchor.constraint(equalTo: topAnchor),
            filterCollectionView.centerYAnchor.constraint(equalTo: centerYAnchor),
            filterCollectionView.heightAnchor.constraint(equalToConstant: 30),
            filterCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            filterCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            //filterCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        filterCollectionView.register(FilterCasesCell.self, forCellWithReuseIdentifier: filterCellReuseIdentifier)
        filterCollectionView.allowsSelection = true
        filterCollectionView.allowsMultipleSelection = false
        filterCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        filterCollectionView.dataSource = self
        filterCollectionView.delegate = self
        
        selectionCellView.layer.cornerRadius = 30 / 2
    }
    
    func selectFirstIndex() {
        DispatchQueue.main.async {
            self.filterCollectionView.selectItem(at: IndexPath(item: 1, section: 0), animated: true, scrollPosition: [])
            self.collectionView(self.filterCollectionView, didSelectItemAt: IndexPath(item: 1, section: 0))
        }
    }
}

extension ExploreCasesToolbar: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Case.FilterCategories.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: filterCellReuseIdentifier, for: indexPath) as! FilterCasesCell
        cell.tagsLabel.text = Case.FilterCategories.allCases[indexPath.row].rawValue
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selection = Case.FilterCategories.allCases[indexPath.row]
        
        if let cell = collectionView.cellForItem(at: indexPath) as? FilterCasesCell {
            
            if !didSelectFirstByDefault {
                self.selectionCellView.frame.origin.x = cell.frame.origin.x
                self.selectionCellView.frame = cell.frame
                self.selectionCellView.frame.origin.y = 10
                didSelectFirstByDefault.toggle()
            } else {
                
                let visibleRect = CGRect(origin: cellPoint, size: collectionView.bounds.size)
                let cellRect = cell.frame
                
                if cellRect.minX < visibleRect.minX {
                    collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
                } else if cellRect.maxX > visibleRect.maxX {
                    collectionView.scrollToItem(at: indexPath, at: .right, animated: true)
                }
                
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                    self.selectionCellView.frame = CGRect(x: cell.frame.origin.x - self.cellPoint.x, y: 10, width: cell.frame.width, height: cell.frame.height)
                }
            }
        }
        
        switch selection {
        case .explore:
           break
        case .all:
            if indexSelected == indexPath.row { return }
            exploreDelegate?.wantsToSeeCategory(category: .all)
            indexSelected = indexPath.row
        case .recents:
            if indexSelected == indexPath.row { return }
            exploreDelegate?.wantsToSeeCategory(category: .recents)
            indexSelected = indexPath.row
        case .solved:
            if indexSelected == indexPath.row { return }
            exploreDelegate?.wantsToSeeCategory(category: .solved)
            indexSelected = indexPath.row
        case .unsolved:
            if indexSelected == indexPath.row { return }
            exploreDelegate?.wantsToSeeCategory(category: .unsolved)
            indexSelected = indexPath.row
        case .you:
            if indexSelected == indexPath.row { return }
            exploreDelegate?.wantsToSeeCategory(category: .you)
            indexSelected = indexPath.row
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            exploreDelegate?.wantsToSeeCategory(category: .explore)
            return false
        }
        return true
    }
}

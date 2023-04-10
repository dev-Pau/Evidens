//
//  SearchAssisstantMenuLauncher.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 5/4/23.
//

import UIKit

private let cellReuseIdentifier = "PostMenuCellReuseIdentifier"
private let footerSearchMenuLauncherReuseIdentifier = "FooterSearchMenuLauncherReuseIdentifier"
private let headerReuseIdentifier = "PostMenuHeaderReuseIdentifier"

protocol SearchAssistantMenuLauncherDelegate: AnyObject {
    func didTapRestoreFilters()
    func didTapShowResults(_ object: NSObject, forTopic topic: String)
    //func didTapShowResultsWithCategory(forCategory category: String)
}

class SearchAssistantMenuLauncher: NSObject {
    
    private let blackBackgroundView: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        return view
    }()
    
    
    weak var delegate: SearchAssistantMenuLauncherDelegate?
    private let searchOptions: [String]
    private var selectedOption = String()
    private var cellPoint: CGPoint!
    
    private var menuHeight: CGFloat = 220
    private let menuYOffset: CGFloat = UIScreen.main.bounds.height
    private var screenWidth: CGFloat = UIScreen.main.bounds.width
    private var didLoad: Bool = false
    
    private var collectionView: UICollectionView!
    
    func showPostSettings(withOption option: String, in view: UIView) {
        screenWidth = view.frame.width
        configurePostSettings(in: view)

        if let footer = collectionView.supplementaryView(forElementKind: ElementKind.sectionFooter, at: IndexPath(item: 0, section: 0)) as? MESearchMenuFooter {
            footer.disableButton()
        }
        //  }
        selectedOption = option
        
        
        if let optionIndex = self.searchOptions.firstIndex(where: { $0 == self.selectedOption }) {
            self.collectionView.selectItem(at: IndexPath(item: optionIndex, section: 0), animated: false, scrollPosition: [])
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blackBackgroundView.alpha = 1
            self.collectionView.frame = CGRect(x: 0, y: self.menuYOffset - self.menuHeight, width: self.screenWidth, height: self.menuHeight)
        }, completion: nil)
    }

    @objc func handleDismiss() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.blackBackgroundView.alpha = 0
            self.collectionView.frame = CGRect(x: 0, y: self.menuYOffset, width: self.screenWidth, height: self.menuHeight)
        } completion: { completed in
        }
    }
    
    @objc func handleDismissMenu() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.blackBackgroundView.alpha = 0
            self.collectionView.frame = CGRect(x: 0, y: self.menuYOffset, width: self.screenWidth, height: self.menuHeight)
        } completion: { _ in
            guard !self.selectedOption.isEmpty else {
                self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
                self.collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: [])
                self.collectionView.deselectItem(at: IndexPath(item: 0, section: 0), animated: false)
                self.collectionView.reloadData()
                return
            }
            if let optionIndex = self.searchOptions.firstIndex(where: { $0 == self.selectedOption }) {
                self.collectionView.scrollToItem(at: IndexPath(item: optionIndex, section: 0), at: .centeredHorizontally, animated: true)
                self.collectionView.selectItem(at: IndexPath(item: optionIndex, section: 0), animated: false, scrollPosition: .centeredHorizontally)
                //self.collectionView.selectItem(at: IndexPath(item: optionIndex, section: 0), animated: true, scrollPosition: .centeredHorizontally)
            }
        }
    }
    
    func configurePostSettings(in view: UIView) {
        view.addSubview(blackBackgroundView)
        view.addSubview(collectionView)
        
        blackBackgroundView.frame = view.frame
        blackBackgroundView.backgroundColor = .label.withAlphaComponent(0.3)
        blackBackgroundView.alpha = 0
        
        blackBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismissMenu)))
        
        collectionView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: screenWidth, height: menuHeight)
    }

    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.layer.cornerRadius = 20
        collectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MESearchMenuHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: headerReuseIdentifier)
        collectionView.register(MESearchMenuFooter.self, forSupplementaryViewOfKind: ElementKind.sectionFooter, withReuseIdentifier: footerSearchMenuLauncherReuseIdentifier)
        collectionView.register(RegistrationInterestsCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView.isScrollEnabled = false
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        collectionView.addGestureRecognizer(pan)
        collectionView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: screenWidth, height: menuHeight)
        collectionView.reloadData()
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(65))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
            let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(320), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: .init(widthDimension: .estimated(320), heightDimension: .absolute(40)), subitems: [item])
            
            group.interItemSpacing = NSCollectionLayoutSpacing.fixed(10)
            
            let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(45))
            let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: ElementKind.sectionFooter, alignment: .bottom)
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 30, trailing: 10)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 10
            section.boundarySupplementaryItems = [header, footer]
            
            section.visibleItemsInvalidationHandler = { (visibleItems, point, env) -> Void in
                self.cellPoint = point
                
            }
            return section
        }
        return layout
    }
    
    @objc func handlePan(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: collectionView)
        
        collectionView.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.height - menuHeight + translation.y * 0.3)
        
        if sender.state == .ended {
            if translation.y > 0 && translation.y > menuHeight * 0.3 {
                UIView.animate(withDuration: 0.3) {
                    //self.handleDismiss(selectedOption: "")
                    self.handleDismiss()
                }
            } else {
                UIView.animate(withDuration: 0.5) {
                    self.collectionView.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.height - self.menuHeight)
                    self.collectionView.frame.size.height = self.menuHeight
                }
            }
        } else {
            collectionView.frame.size.height = menuHeight - translation.y * 0.3
        }
    }
    
    init(searchOptions: [String]) {
        self.searchOptions = searchOptions
        super.init()
        configureCollectionView()
    }
}
    

extension SearchAssistantMenuLauncher: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == ElementKind.sectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! MESearchMenuHeader
            header.delegate = self
            header.menuTitle.text = "Show"
            return header
        } else {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerSearchMenuLauncherReuseIdentifier, for: indexPath) as! MESearchMenuFooter
            footer.delegate = self
            return footer
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! RegistrationInterestsCell
        cell.setText(text: searchOptions[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedOption = searchOptions[indexPath.row]
        
        if let footer = collectionView.supplementaryView(forElementKind: ElementKind.sectionFooter, at: IndexPath(item: 0, section: 0)) as? MESearchMenuFooter, let cell = collectionView.cellForItem(at: indexPath) as? RegistrationInterestsCell {
            footer.didSelectOption(selectedOption)
            
            let visibleRect = CGRect(origin: cellPoint, size: collectionView.bounds.size)
            let cellRect = cell.frame
            
            if cellRect.minX < visibleRect.minX {
                // Cell is more to the left, so configure it accordingly
                collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
                //collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
                // ...
            } else if cellRect.maxX > visibleRect.maxX {
                // Cell is more to the right, so configure it accordingly
                collectionView.scrollToItem(at: indexPath, at: .right, animated: true)
                //collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .right)
                // ..
            }
            
        }
    }
}



extension SearchAssistantMenuLauncher: MESearchMenuFooterDelegate {
    func handleShowResults(withOption option: String) {
        //delegate?.didTapUpload(content: option)
        delegate?.didTapShowResults(self, forTopic: option)
        selectedOption = option
        /*
        if let optionIndex = self.searchOptions.firstIndex(where: { $0 == self.selectedOption }) {
            self.collectionView.selectItem(at: IndexPath(item: optionIndex, section: 0), animated: false, scrollPosition: [])
        }
        */
        handleDismissMenu()
    }
}

extension SearchAssistantMenuLauncher: MESearchMenuHeaderDelegate {
    func didTapResetFilters() {
        selectedOption = String()
        delegate?.didTapRestoreFilters()
    }
}


//
//  SearchMenu.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 5/4/23.
//

import UIKit

private let cellReuseIdentifier = "PostMenuCellReuseIdentifier"
private let footerSearchMenuLauncherReuseIdentifier = "FooterSearchMenuLauncherReuseIdentifier"
private let headerReuseIdentifier = "PostMenuHeaderReuseIdentifier"

protocol SearchMenuDelegate: AnyObject {
    func didTapRestoreFilters()
    func didTapShowResults(forTopic topic: SearchTopics)
    func didTapShowResults(forDiscipline discipline: Discipline)
}

class SearchMenu: NSObject {
    
    private let blackBackgroundView: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        return view
    }()
    
    private let kind: SearchKind
    
    private var topic: SearchTopics?
    private var discipline: Discipline?
    
    weak var delegate: SearchMenuDelegate?
    private var cellPoint: CGPoint!
    
    private var topics: [SearchTopics]?
    
    private var menuHeight: CGFloat = 220
    private let menuYOffset: CGFloat = UIScreen.main.bounds.height
    private var screenWidth: CGFloat = UIScreen.main.bounds.width
    private var didLoad: Bool = false
    
    private var collectionView: UICollectionView!
    
    func showMenu(withTopic topic: SearchTopics, in view: UIView) {
        self.topic = topic
        configurePostSettings(in: view)
        
        if let footer = collectionView.supplementaryView(forElementKind: ElementKind.sectionFooter, at: IndexPath(item: 0, section: 0)) as? SearchMenuFooter {
            footer.disableButton()
        }
        
        if let optionIndex = SearchTopics.allCases.firstIndex(where: { $0 == self.topic }) {
            collectionView.selectItem(at: IndexPath(item: optionIndex, section: 0), animated: false, scrollPosition: [])
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.blackBackgroundView.alpha = 1
            strongSelf.collectionView.frame = CGRect(x: 0, y: strongSelf.menuYOffset - strongSelf.menuHeight, width: strongSelf.screenWidth, height: strongSelf.menuHeight)
        }, completion: nil)
    }
    
    func showMenu(withDiscipline discipline: Discipline, in view: UIView) {
        self.discipline = discipline
        configurePostSettings(in: view)
        
        if let footer = collectionView.supplementaryView(forElementKind: ElementKind.sectionFooter, at: IndexPath(item: 0, section: 0)) as? SearchMenuFooter {
            footer.disableButton()
        }
        
        if let optionIndex = Discipline.allCases.firstIndex(where: { $0 == self.discipline }) {
            collectionView.selectItem(at: IndexPath(item: optionIndex, section: 0), animated: false, scrollPosition: [])
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.blackBackgroundView.alpha = 1
            strongSelf.collectionView.frame = CGRect(x: 0, y: strongSelf.menuYOffset - strongSelf.menuHeight, width: strongSelf.screenWidth, height: strongSelf.menuHeight)
        }, completion: nil)
    }
    
    func showPostSettings(withOption option: String, in view: UIView) {

    }
    
    @objc func handleDismiss() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.blackBackgroundView.alpha = 0
            self.collectionView.frame = CGRect(x: 0, y: self.menuYOffset, width: self.screenWidth, height: self.menuHeight)
        } completion: { completed in
        }
    }
    
    @objc func handleDismissMenu() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 1, options: .curveEaseOut) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.blackBackgroundView.alpha = 0
            strongSelf.collectionView.frame = CGRect(x: 0, y: strongSelf.menuYOffset, width: strongSelf.screenWidth, height: strongSelf.menuHeight)
        } completion: { [weak self] _ in
            guard let strongSelf = self else { return }
            
            switch strongSelf.kind {
            case .topics:
                guard strongSelf.topic != nil else {
                    strongSelf.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
                    strongSelf.collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: [])
                    strongSelf.collectionView.deselectItem(at: IndexPath(item: 0, section: 0), animated: false)
                    strongSelf.collectionView.reloadData()
                    return
                }
                
                if let index = SearchTopics.allCases.firstIndex(where: { $0 == strongSelf.topic }) {
                    strongSelf.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
                    strongSelf.collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: .centeredHorizontally)
                }
                
            case .disciplines:
                guard strongSelf.discipline != nil else {
                    strongSelf.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
                    strongSelf.collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: [])
                    strongSelf.collectionView.deselectItem(at: IndexPath(item: 0, section: 0), animated: false)
                    strongSelf.collectionView.reloadData()
                    return
                }
                
                if let index = Discipline.allCases.firstIndex(where: { $0 == strongSelf.discipline }) {
                    strongSelf.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
                    strongSelf.collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: .centeredHorizontally)
                }
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
        collectionView.register(SearchMenuHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: headerReuseIdentifier)
        collectionView.register(SearchMenuFooter.self, forSupplementaryViewOfKind: ElementKind.sectionFooter, withReuseIdentifier: footerSearchMenuLauncherReuseIdentifier)
        collectionView.register(ChoiceCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
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
    
    /*
    init(searchOptions: [String]) {
        self.searchOptions = searchOptions
        super.init()
        configureCollectionView()
    }
    */
    init(kind: SearchKind) {
        self.kind = kind
        super.init()
    }
}
    

extension SearchMenu: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == ElementKind.sectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! SearchMenuHeader
            header.delegate = self
            //header.menuTitle.text = "Show"
            return header
        } else {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerSearchMenuLauncherReuseIdentifier, for: indexPath) as! SearchMenuFooter
            footer.delegate = self
            return footer
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch kind {
        case .topics:
            return SearchTopics.allCases.count
        case .disciplines:
            return Discipline.allCases.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! ChoiceCell
        
        switch kind {
        case .topics:
            cell.set(searchTopic: SearchTopics.allCases[indexPath.row])
        case .disciplines:
            cell.set(discipline: Discipline.allCases[indexPath.row])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let footer = collectionView.supplementaryView(forElementKind: ElementKind.sectionFooter, at: IndexPath(item: 0, section: 0)) as? SearchMenuFooter, let cell = collectionView.cellForItem(at: indexPath) as? ChoiceCell {
            switch kind {
            case .topics:
                let topic = SearchTopics.allCases[indexPath.row]
                footer.set(topic)
            case .disciplines:
                let discipline = Discipline.allCases[indexPath.row]
                footer.set(discipline)
            }
            
            let visibleRect = CGRect(origin: cellPoint, size: collectionView.bounds.size)
            let cellRect = cell.frame
            
            if cellRect.minX < visibleRect.minX {
                collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
            } else if cellRect.maxX > visibleRect.maxX {
                collectionView.scrollToItem(at: indexPath, at: .right, animated: true)
            }
        }
    }
}



extension SearchMenu: SearchMenuFooterDelegate {
    func handleShowResults(withTopic topic: SearchTopics) {
        delegate?.didTapShowResults(forTopic: topic)
        self.topic = topic
        
        /*
        if let optionIndex = self.searchOptions.firstIndex(where: { $0 == self.selectedOption }) {
            self.collectionView.selectItem(at: IndexPath(item: optionIndex, section: 0), animated: false, scrollPosition: [])
        }
        */
        
        handleDismissMenu()
        
        
    }
    
    func handleShowResults(withDiscipline discipline: Discipline) {
        delegate?.didTapShowResults(forDiscipline: discipline)
        self.discipline = discipline
        
        /*
        if let optionIndex = self.searchOptions.firstIndex(where: { $0 == self.selectedOption }) {
            self.collectionView.selectItem(at: IndexPath(item: optionIndex, section: 0), animated: false, scrollPosition: [])
        }
        */
        
        handleDismissMenu()
    }
    
    func handleShowResults(withOption option: String) {
        /*
        //delegate?.didTapUpload(content: option)
        delegate?.didTapShowResults(self, forTopic: option)
        switch kind {
        case .topics:
            topic = 
        case .disciplines:
            <#code#>
        }
        selectedOption = option
       
        handleDismissMenu()
         */
    }
}

extension SearchMenu: SearchMenuHeaderDelegate {
    func didTapResetFilters() {
        self.discipline = nil
        self.topic = nil
        delegate?.didTapRestoreFilters()
    }
}


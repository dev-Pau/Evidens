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
    func didSelectSearchTopic(_ category: SearchTopics)
    
    func showMenuFor(discipline: Discipline)
    func showMenuFor(searchTopic: SearchTopics)
}

class SearchToolbar: UIToolbar {
    weak var searchDelegate: SearchToolbarDelegate?
    private var collectionView: UICollectionView!
    
    private var discipline: Discipline?
    private var searchTopic: SearchTopics?
    
    private var searchMode: SearchMode = .discipline
    
    private let dataSource = Discipline.allCases.map { $0.name }

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
    
    func didSelectDisciplineFromMenu(_ discipline: Discipline) {
        guard let currentDiscipline = self.discipline, currentDiscipline != discipline else { return }
        switch searchMode {
        case .discipline:
            break
        case .topic, .choose:
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.collectionView.alpha = 0
            } completion: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.searchMode = .topic
                strongSelf.collectionView.reloadData()
                strongSelf.searchDelegate?.didSelectDiscipline(discipline)
                strongSelf.discipline = discipline
                UIView.animate(withDuration: 0.2) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.collectionView.alpha = 1
                }
            }
        }
    }
    
    func didSelectTopicFromMenu(_ searchTopic: SearchTopics) {
        guard let currentSearchTopic = self.searchTopic, currentSearchTopic != searchTopic else { return }
        searchMode = .choose
        self.searchTopic = searchTopic
        collectionView.reloadData()
        searchDelegate?.didSelectSearchTopic(searchTopic)
    }
    
    func didRestoreMenu() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.alpha = 0
            strongSelf.separatorView.backgroundColor = .systemBackground
        } completion: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
            strongSelf.searchMode = .discipline
            strongSelf.searchTopic = nil
            strongSelf.discipline = nil
            strongSelf.collectionView.reloadData()
            strongSelf.collectionView.frame.origin.y = -50
            strongSelf.collectionView.alpha = 1

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseIn) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.collectionView.frame.origin.y = 0
                strongSelf.separatorView.backgroundColor = strongSelf.separatorColor
                strongSelf.searchDelegate?.didRestoreMenu()
            }
        }
    }
    
    func getDiscipline() -> Discipline? {
        return discipline
    }
}

extension SearchToolbar: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch searchMode {
        case .discipline:
            return Discipline.allCases.count
        case .topic:
            return SearchTopics.allCases.count + 1
        case .choose:
            return 2
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
        case .choose:
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: professionSelectedCellReuseIdentifier, for: indexPath) as! SearchToolbarCell
                if let discipline {
                    cell.set(discipline: discipline)
                }
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: filterCellReuseIdentifier, for: indexPath) as! FilterCasesCell
                cell.changeAppearanceOnSelection = false
                if let searchTopic {
                    cell.set(searchTopic: searchTopic)
                }
                
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

                strongSelf.searchMode = .topic
                strongSelf.discipline = Discipline.allCases[indexPath.row]

                strongSelf.collectionView.reloadData()
                strongSelf.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
                strongSelf.searchDelegate?.didSelectDiscipline(Discipline.allCases[indexPath.row])

            }
        case .topic:
            collectionView.performBatchUpdates { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.searchTopic = SearchTopics.allCases[indexPath.row - 1]
                collectionView.moveItem(at: indexPath, to: IndexPath(item: 1, section: 0))

            } completion: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.searchMode = .choose
                strongSelf.collectionView.reloadData()
                if let searchTopic = strongSelf.searchTopic {
                    strongSelf.searchDelegate?.didSelectSearchTopic(searchTopic)
                }
            }
        case .choose:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        switch searchMode {
            
        case .discipline:
            return true

        case .topic:
            if indexPath.row == 0 {
                guard let discipline else {
                    return false
                }
                
                searchDelegate?.showMenuFor(discipline: discipline)
                return false
            } else {
                return true
            }
        case .choose:
            if indexPath.row == 0 {
                guard let discipline else {
                    return false
                }
                searchDelegate?.showMenuFor(discipline: discipline)
            } else {
                guard let searchTopic else {
                    return false
                }
                searchDelegate?.showMenuFor(searchTopic: searchTopic)
            }
            return false
        }
    }
}

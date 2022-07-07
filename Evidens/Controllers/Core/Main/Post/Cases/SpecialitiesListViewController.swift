//
//  SpecialitiesListViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 5/7/22.
//

import UIKit

private let specialitiesCellReuseIdentifier = "SpecialitiesCellReuseIdentifier"

protocol SpecialitiesListViewControllerDelegate: AnyObject {
    func presentSpecialities(_ specialities: [String])
}

class SpecialitiesListViewController: UIViewController {
    
    enum Section { case main }
    
    weak var delegate: SpecialitiesListViewControllerDelegate?
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Speciality>!
    
    private var specialities = Speciality.allSpecialities()
    private var highlights: [Bool] = []
    
    private var filteredSpecialities: [Speciality] = []
    
    private var isSearching: Bool = false
    
    private let searchController = UISearchController()
    private var specialitiesSelected: [String] = []
    
    var previousSpecialities: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        highlights = Speciality.isHighlighted(speciality: specialities)
        configureNavigationBar()
        configureSearchBar()
        configureCollectionView()
        configureDataSource()
        updateData(on: specialities)
        configurePreviousSpecialities()
        print(highlights.count)
        print(specialities.count)
    }
    
    
    private func configureNavigationBar() {
        title = "Add specialities"
        navigationItem.hidesSearchBarWhenScrolling = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add 0/5", style: .done, target: self, action: #selector(handleAddSpecialities))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func configureSearchBar() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Specialities"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    func createTwoColumnFlowLayout() -> UICollectionViewFlowLayout {
        let width = view.bounds.width
        let padding: CGFloat = 12
        let minimumItemSpacing: CGFloat = 6
        let availableWidth = width - padding * 2 - minimumItemSpacing * 2
        let cellWidth = availableWidth / 2
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: minimumItemSpacing, left: padding, bottom: minimumItemSpacing, right: padding)
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth / 2.5)
        return layout
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createTwoColumnFlowLayout())
        collectionView.keyboardDismissMode = .interactive
        collectionView.allowsMultipleSelection = true
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.register(SpecialitiesDiffableCell.self, forCellWithReuseIdentifier: specialitiesCellReuseIdentifier)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Speciality>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, speciality) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: specialitiesCellReuseIdentifier, for: indexPath) as! SpecialitiesDiffableCell
            cell.specialityLabel.text = speciality.name
            return cell
        })
    }
    
    private func updateData(on specialities: [Speciality]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Speciality>()
        snapshot.appendSections([.main])
        snapshot.appendItems(specialities)
        
        let indexSelected = collectionView.indexPathsForSelectedItems
        
        specialitiesSelected.forEach { speciality in
            if (snapshot.sectionIdentifier(containingItem: Speciality(name: speciality)) != nil) {
            } else {
                snapshot.appendItems([Speciality(name: speciality)])
            }
        }
        
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    private func configurePreviousSpecialities() {
        
    }
    
    @objc func handleAddSpecialities() {
        delegate?.presentSpecialities(specialitiesSelected)
        navigationController?.popViewController(animated: true)
    }
}

extension SpecialitiesListViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            filteredSpecialities.removeAll()
            updateData(on: specialities)
            isSearching = false
            return
        }
        isSearching = true
        filteredSpecialities = specialities.filter{ $0.name.lowercased().contains(filter.lowercased()) }
        
        updateData(on: filteredSpecialities)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        updateData(on: specialities)
    }
}

extension SpecialitiesListViewController: UICollectionViewDelegate {
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SpecialitiesDiffableCell else { return }

        if let text = cell.specialityLabel.text {
            specialitiesSelected.append(text)
            navigationItem.rightBarButtonItem?.isEnabled = true
            navigationItem.rightBarButtonItem?.title = "Add \(specialitiesSelected.count)/5"
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SpecialitiesDiffableCell else { return }
        if let text = cell.specialityLabel.text {
            if let index = specialitiesSelected.firstIndex(where: { $0 == text }) {
                specialitiesSelected.remove(at: index)
                navigationItem.rightBarButtonItem?.title = "Add \(specialitiesSelected.count)/5"
                if specialitiesSelected.isEmpty { navigationItem.rightBarButtonItem?.isEnabled = false }
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if specialitiesSelected.count == 5 {
            return false
        }
        return collectionView.indexPathsForSelectedItems!.count <= 4
    }
}

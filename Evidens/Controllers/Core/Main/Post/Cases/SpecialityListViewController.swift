//
//  SpecialitiesListViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 5/7/22.
//

import UIKit

private let specialitiesCellReuseIdentifier = "SpecialitiesCellReuseIdentifier"

protocol SpecialityListViewControllerDelegate: AnyObject {
    func presentSpecialities(_ specialities: [Speciality])
}

class SpecialityListViewController: UIViewController {
    
    enum Section { case main }
    
    weak var delegate: SpecialityListViewControllerDelegate?
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Speciality>!
    
    private var specialities = [Speciality]()
    private var filteredSpecialities: [Speciality] = []
    private var professions: [Discipline]
    private var specialitiesSelected = [Speciality]()
    
    private var isSearching: Bool = false
    
    private var searchController: UISearchController!
    private let maxCount = 4
    
    
    var previousSpecialities: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        professions.forEach { profession in
            self.specialities.append(contentsOf: profession.specialities)
        }
 
        configureNavigationBar()
        configureSearchBar()
        configureCollectionView()
        configureDataSource()
        updateData(on: specialities)
    }
    
    init(filteredSpecialities: [Speciality], professions: [Discipline]) {
        self.specialitiesSelected = filteredSpecialities
        self.professions = professions
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = AppStrings.Opening.specialities
        navigationItem.hidesSearchBarWhenScrolling = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: AppStrings.Global.add + " " + "\(specialitiesSelected.count)/\(maxCount)", style: .done, target: self, action: #selector(handleAddSpecialities))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        navigationItem.rightBarButtonItem?.isEnabled = specialitiesSelected.count > 0 ? true : false
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.setBackIndicatorImage(UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), transitionMaskImage: UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label))
        navigationBarAppearance.configureWithOpaqueBackground()
        
        let barButtonItemAppearance = UIBarButtonItemAppearance()
        barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        navigationBarAppearance.backButtonAppearance = barButtonItemAppearance
        
        navigationBarAppearance.shadowColor = separatorColor
        navigationBarAppearance.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 17, weight: .heavy)]
        
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance

    }
    
    private func configureSearchBar() {
        searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.searchTextField.layer.cornerRadius = 17
        searchController.searchBar.searchTextField.layer.masksToBounds = true
        searchController.searchBar.placeholder = AppStrings.Opening.speciality
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    func createTwoColumnFlowLayout() -> UICollectionViewFlowLayout {
        let width = view.bounds.width
        let padding: CGFloat = 12
        let minimumItemSpacing: CGFloat = 6
        let availableWidth = width - padding * 2 - minimumItemSpacing * 2
        let cellWidth = availableWidth / 2
        
        let fontHeight = UIFont.addFont(size: 15, scaleStyle: .largeTitle, weight: .semibold).lineHeight * 3 + 30

        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: minimumItemSpacing, left: padding, bottom: minimumItemSpacing, right: padding)
        layout.itemSize = CGSize(width: cellWidth, height: fontHeight)
        return layout
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createTwoColumnFlowLayout())
        collectionView.keyboardDismissMode = .onDrag
        collectionView.allowsMultipleSelection = true
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.register(PrimarySpecialityCell.self, forCellWithReuseIdentifier: specialitiesCellReuseIdentifier)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Speciality>(collectionView: collectionView, cellProvider: { [weak self] (collectionView, indexPath, speciality) -> UICollectionViewCell? in
            guard let strongSelf = self else { return nil }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: specialitiesCellReuseIdentifier, for: indexPath) as! PrimarySpecialityCell
            cell.set(speciality: speciality)
            
            if strongSelf.specialitiesSelected.contains(speciality) {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
            }
            
            return cell
        })
    }
    
    private func updateData(on specialities: [Speciality]) {

        var snapshot = NSDiffableDataSourceSnapshot<Section, Speciality>()
        snapshot.appendSections([.main])
        snapshot.appendItems(specialities)

        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    @objc func handleAddSpecialities() {
        delegate?.presentSpecialities(specialitiesSelected)
        navigationController?.popViewController(animated: true)
    }
}

extension SpecialityListViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            filteredSpecialities.removeAll()
            updateData(on: specialities)
            isSearching = false
            return
        }
        isSearching = true
        filteredSpecialities = specialities.filter { $0.name.lowercased().contains(filter.lowercased()) }
        
        updateData(on: filteredSpecialities)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        updateData(on: specialities)
    }
}

extension SpecialityListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let speciality = isSearching ? filteredSpecialities[indexPath.row] : specialities[indexPath.row]
        specialitiesSelected.append(speciality)
        navigationItem.rightBarButtonItem?.isEnabled = true
        navigationItem.rightBarButtonItem?.title = AppStrings.Global.add + " " + "\(specialitiesSelected.count)/\(maxCount)"
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let speciality = isSearching ? filteredSpecialities[indexPath.row] : specialities[indexPath.row]
        if let index = specialitiesSelected.firstIndex(where: { $0 == speciality }) {
            specialitiesSelected.remove(at: index)
            navigationItem.rightBarButtonItem?.title = AppStrings.Global.add + " " + "\(specialitiesSelected.count)/\(maxCount)"
            if specialitiesSelected.isEmpty { navigationItem.rightBarButtonItem?.isEnabled = false }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if specialitiesSelected.count == 4 {
            return false
        }
        return collectionView.indexPathsForSelectedItems!.count <= 4
    }
}

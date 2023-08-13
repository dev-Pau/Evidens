//
//  SpecialityRegistrationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/7/22.
//

import UIKit

private let registerCellReuseIdentifier = "RegisterCellReuseIdentifier"

protocol SpecialityRegistrationViewControllerDelegate: AnyObject {
    func didEditSpeciality(speciality: Speciality)
}

class SpecialityViewController: UIViewController {
    
    private var user: User
    
    weak var delegate: SpecialityRegistrationViewControllerDelegate?
    
    var isEditingProfileSpeciality: Bool = false

    enum Section { case main }
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        return collectionView
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Speciality>!
    
    private var specialities = [Speciality]()
    private var filteredSpecialities = [Speciality]()
    private var speciality: Speciality?
    
    private var isSearching: Bool = false
    
    private var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureSearchBar()
        configureUI()
        configureData()
        configureCollectionView()
        configureDataSource()
        updateData(on: specialities)
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = isEditingProfileSpeciality ? AppStrings.Opening.speciality : ""
        navigationItem.hidesSearchBarWhenScrolling = false

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: isEditingProfileSpeciality ? AppStrings.Miscellaneous.change : AppStrings.Miscellaneous.next, style: .done, target: self, action: #selector(handleNext))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func configureSearchBar() {
        searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = AppStrings.Opening.speciality
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = primaryColor
        navigationItem.searchController = searchController
    }
    
    private func configureData() {
        guard let discipline = user.discipline else { return }
        specialities = discipline.specialities
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.frame = view.bounds
        collectionView.delegate = self
        collectionView.register(RegisterCell.self, forCellWithReuseIdentifier: registerCellReuseIdentifier)
        view.addSubview(collectionView)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Speciality>(collectionView: collectionView, cellProvider: { [weak self] collectionView, indexPath, speciality in
            guard let strongSelf = self else { return nil }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: registerCellReuseIdentifier, for: indexPath) as! RegisterCell
            cell.set(value: speciality.name)

            if strongSelf.isEditingProfileSpeciality, let userSpeciality = strongSelf.user.speciality {
                if speciality == userSpeciality { collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left) }
            }
            
            return cell
        })
    }
    
    private func updateData(on  specialities: [Speciality]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Speciality>()
        snapshot.appendSections([.main])
        snapshot.appendItems(specialities)
        
        
        if let currentSpeciality = self.speciality {
            if snapshot.sectionIdentifier(containingItem: currentSpeciality) == nil {
                snapshot.appendItems([currentSpeciality])
            }
        }

        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
    }
    
    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleNext() {
        if isEditingProfileSpeciality {
            guard let speciality = self.speciality else { return }
            delegate?.didEditSpeciality(speciality: speciality)
            navigationController?.popViewController(animated: true)
            return
        }
        
        guard let discipline = user.discipline,
              let speciality = user.speciality,
              let uid = user.uid else { return }
        
        let kind = user.kind

        let credentials = AuthCredentials(uid: uid, phase: .details, kind: kind, discipline: discipline, speciality: speciality)

        showProgressIndicator(in: view)

        AuthService.setProfesionalDetails(withCredentials: credentials) { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.dismissProgressIndicator()
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            } else {
                let controller = FullNameViewController(user: strongSelf.user)
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true)
            }
        }
    }
}

extension SpecialityViewController: UISearchResultsUpdating, UISearchBarDelegate {
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

extension SpecialityViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        speciality = isSearching ? filteredSpecialities[indexPath.row] : specialities[indexPath.row]
        user.speciality = speciality
        searchController.dismiss(animated: true)
        searchBarCancelButtonClicked(searchController.searchBar)
        searchController.searchBar.searchTextField.text = ""
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
}

extension SpecialityViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
}



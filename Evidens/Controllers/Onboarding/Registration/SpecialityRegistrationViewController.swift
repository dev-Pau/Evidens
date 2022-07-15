//
//  SpecialityRegistrationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/7/22.
//

import UIKit

private let registerCellReuseIdentifier = "RegisterCellReuseIdentifier"

class SpecialityRegistrationViewController: UIViewController {
    
    private var user: User
    
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
    
    private var specialities: [Speciality] = []
    private var filteredSpecialities: [Speciality] = []
    
    private var selectedSpeciality: String = ""
    private var isSearching: Bool = false
    
    private let searchController = UISearchController()

    
    
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
        title = "Add Speciality"
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .init(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(didTapBack))
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(handleNext))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func configureSearchBar() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Specialities"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = primaryColor
        navigationItem.searchController = searchController
    }
    
    private func configureData() {
        switch user.category {
        case .none:
            print("Pending to configure")
            break
        case .professional:
            print("Pending to configure")
            break
        case .professor:
            print("Pending to configure")
            break
        case .student:
            
            switch user.profession {
            case "Odontology":
                specialities = Speciality.odontologySpecialities()
                selectedSpeciality = "General Odontology"
            default:
                print("Pending to configure")
            }
        case .researcher:
            print("Pending to configure")
            break
        }
    }
    
    private func configureCollectionView() {
        collectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        collectionView.delegate = self
        collectionView.register(RegisterCell.self, forCellWithReuseIdentifier: registerCellReuseIdentifier)
        view.addSubview(collectionView)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Speciality>(collectionView: collectionView, cellProvider: { collectionView, indexPath, speciality in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: registerCellReuseIdentifier, for: indexPath) as! RegisterCell
            cell.set(value: speciality.name)
            return cell
        })
    }
    
    private func updateData(on  specialities: [Speciality]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Speciality>()
        snapshot.appendSections([.main])
        snapshot.appendItems(specialities)
        
        if snapshot.sectionIdentifier(containingItem: Speciality(name: selectedSpeciality)) == nil {
            snapshot.appendItems([Speciality(name: selectedSpeciality)])
        }
        
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private func configureUI() {
        view.backgroundColor = .white
    }
    
    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleNext() {
        guard let email = user.email,
              let profession = user.profession,
              let speciality = user.speciality,
              let uid = user.uid else { return }
        
        let credentials = AuthCredentials(firstName: "", lastName: "", email: email, password: "", profileImageUrl: "", phase: .userDetailsPhase, category: user.category, profession: profession, speciality: speciality)
        
        AuthService.updateUserRegistrationData(withUid: uid, withCredentials: credentials) { error in
            if let error = error {
                self.displayAlert(withTitle: "Error", withMessage: error.localizedDescription)
                return
            }
            
            let controller = FullNameViewController(user: self.user)
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
    }
}
    
    extension SpecialityRegistrationViewController: UISearchResultsUpdating, UISearchBarDelegate {
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

extension SpecialityRegistrationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? RegisterCell else { return }
        if let text = cell.professionLabel.text {
            selectedSpeciality = text
            user.speciality = selectedSpeciality
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
}

extension SpecialityRegistrationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
}



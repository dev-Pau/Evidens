//
//  ProfessionRegistrationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/7/22.
//

import UIKit
import MessageUI

private let registerProfessionCellReuseIdentifier = "RegisterProfessionCellReuseIdentifier"

class ProfessionRegistrationViewController: UIViewController {
    
    private var user: User
    
    enum Section { case main }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Profession>!
    
    private var professions: [Profession] = Profession.getAllProfessions()
    private var filteredProfessions: [Profession] = []
    
    private var selectedProfession: String = "Medicine"
    private var isSearching: Bool = false
    
    private let searchController = UISearchController()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.keyboardDismissMode = .interactive
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureSearchBar()
        configureUI()
        configureCollectionView()
        configureDataSource()
        updateData(on: professions)
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        if user.category == .professional {
            title = "Add Profession"
        } else {
            title = "Add field of study"
        }

        navigationItem.hidesSearchBarWhenScrolling = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(handleNext))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func configureSearchBar() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        if user.category == .professional {
            searchController.searchBar.placeholder = "Profession"
        } else {
            searchController.searchBar.placeholder = "Field of study"
        }

        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = primaryColor
        navigationItem.searchController = searchController
    }
   
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Profession>(collectionView: collectionView, cellProvider: { collectionView, indexPath, profession in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: registerProfessionCellReuseIdentifier, for: indexPath) as! RegisterCell
            cell.set(value: profession.profession)
            return cell
        })
    }
    
    private func configureCollectionView() {
        collectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.register(RegisterCell.self, forCellWithReuseIdentifier: registerProfessionCellReuseIdentifier)
        view.addSubview(collectionView)
    }
    
    private func updateData(on  professions: [Profession]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Profession>()
        snapshot.appendSections([.main])
        snapshot.appendItems(professions)
        
        if snapshot.sectionIdentifier(containingItem: Profession(profession: selectedProfession)) == nil {
            snapshot.appendItems([Profession(profession: selectedProfession)])
        }
        
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
    }
    
    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleNext() {
        let controller = SpecialityRegistrationViewController(user: user)
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension ProfessionRegistrationViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
        filteredProfessions.removeAll()
        updateData(on: professions)
        isSearching = false
        return
        }
        
        isSearching = true
        filteredProfessions = professions.filter { $0.profession.lowercased().contains(filter.lowercased()) }
        
        updateData(on: filteredProfessions)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        updateData(on: professions)
    }
}

extension ProfessionRegistrationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? RegisterCell else { return }
        if let text = cell.professionLabel.text {
            selectedProfession = text
            user.profession = selectedProfession
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
}

extension ProfessionRegistrationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
}

extension ProfessionRegistrationViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true)
        }
        
        controller.dismiss(animated: true)
    }
}

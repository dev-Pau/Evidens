//
//  ProfessionRegistrationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/7/22.
//

import UIKit
import MessageUI

private let registerProfessionCellReuseIdentifier = "RegisterProfessionCellReuseIdentifier"

class DisciplineViewController: UIViewController {
    
    private var viewModel: DisciplineViewModel

    var dataSource: UICollectionViewDiffableDataSource<Section, Discipline>!
    
    enum Section { case main }
    
    private var searchController: UISearchController!
    
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureSearchBar()
        configureUI()
        configureCollectionView()
        configureDataSource()
        updateData(on: viewModel.disciplines)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchController.searchBar.searchTextField.layer.cornerRadius = searchController.searchBar.searchTextField.frame.height / 2
        searchController.searchBar.searchTextField.clipsToBounds = true
    }
    
    init(user: User) {
        self.viewModel = DisciplineViewModel(user: user)
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        searchController = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        addNavigationBarLogo(withTintColor: primaryColor)
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: AppStrings.Miscellaneous.next, style: .done, target: self, action: #selector(handleNext))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func configureSearchBar() {
        searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        if viewModel.user.kind == .professional {
            searchController.searchBar.placeholder = AppStrings.Opening.discipline
        } else {
            searchController.searchBar.placeholder = AppStrings.Opening.fieldOfStudy
        }

        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = primaryColor
        navigationItem.searchController = searchController
        
        if #available(iOS 16.0, *) {
            navigationItem.preferredSearchBarPlacement = .stacked
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardFrameChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
   
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Discipline>(collectionView: collectionView, cellProvider: { collectionView, indexPath, discipline in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: registerProfessionCellReuseIdentifier, for: indexPath) as! RegisterCell
            cell.set(value: discipline.name)
            return cell
        })
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: addLayout())
        collectionView.keyboardDismissMode = .onDrag
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = true

        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.register(RegisterCell.self, forCellWithReuseIdentifier: registerProfessionCellReuseIdentifier)
        view.addSubview(collectionView)
    }
    
    private func addLayout() -> UICollectionViewCompositionalLayout {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func updateData(on discipline: [Discipline]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Discipline>()
        snapshot.appendSections([.main])
        snapshot.appendItems(discipline)
        
        if let currentDiscipline = viewModel.discipline {
            if snapshot.sectionIdentifier(containingItem: currentDiscipline) == nil {
                snapshot.appendItems([currentDiscipline])
                viewModel.filteredDisciplines.append(currentDiscipline)
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
        guard let discipline = viewModel.discipline else { return }
        viewModel.user.discipline = discipline
        let controller = SpecialityViewController(user: viewModel.user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleKeyboardFrameChange(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect, let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }
        
        let convertedKeyboardFrame = view.convert(keyboardFrame, from: nil)
        let intersection = convertedKeyboardFrame.intersection(view.bounds)
        
        let keyboardHeight = view.bounds.maxY - intersection.minY
        
        let constant = -(keyboardHeight)

        UIView.animate(withDuration: animationDuration) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.contentInset.bottom = -constant
            strongSelf.collectionView.verticalScrollIndicatorInsets.bottom = -constant
            strongSelf.view.layoutIfNeeded()
        }
    }

}

extension DisciplineViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            viewModel.filteredDisciplines.removeAll()
            updateData(on: viewModel.disciplines)
            viewModel.isSearching = false
            return
        }
        
        viewModel.isSearching = true
        viewModel.filteredDisciplines = viewModel.disciplines.filter { $0.name.lowercased().contains(filter.lowercased()) }
        updateData(on: viewModel.filteredDisciplines)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.isSearching = false
        updateData(on: viewModel.disciplines)
    }
}

extension DisciplineViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.discipline = viewModel.isSearching ? viewModel.filteredDisciplines[indexPath.row] : viewModel.disciplines[indexPath.row]
        searchController.dismiss(animated: true)
        searchBarCancelButtonClicked(searchController.searchBar)
        searchController.searchBar.searchTextField.text = ""
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
}

extension DisciplineViewController: UICollectionViewDelegateFlowLayout {
    
}

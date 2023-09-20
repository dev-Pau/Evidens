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
    
    private var user: User
    
    enum Section { case main }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Discipline>!
    
    private var disciplines: [Discipline] = Discipline.allCases
    private var filteredDisciplines = [Discipline]()
    
    private var discipline: Discipline?
    private var isSearching: Bool = false
    
    private var searchController: UISearchController!
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.keyboardDismissMode = .onDrag
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = true
        return collectionView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureSearchBar()
        configureUI()
        configureCollectionView()
        configureDataSource()
        updateData(on: disciplines)
    }
    
    init(user: User) {
        self.user = user
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
        
        if user.kind == .professional {
            searchController.searchBar.placeholder = AppStrings.Opening.discipline
        } else {
            searchController.searchBar.placeholder = AppStrings.Opening.fieldOfStudy
        }

        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = primaryColor
        navigationItem.searchController = searchController
        
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
        collectionView.frame = view.bounds
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.register(RegisterCell.self, forCellWithReuseIdentifier: registerProfessionCellReuseIdentifier)
        view.addSubview(collectionView)
    }
    
    private func updateData(on discipline: [Discipline]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Discipline>()
        snapshot.appendSections([.main])
        snapshot.appendItems(discipline)
        
        if let currentDiscipline = self.discipline {
            if snapshot.sectionIdentifier(containingItem: currentDiscipline) == nil {
                snapshot.appendItems([currentDiscipline])
                filteredDisciplines.append(currentDiscipline)
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
        guard let discipline = discipline else { return }
        user.discipline = discipline
        let controller = SpecialityViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleKeyboardFrameChange(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect, let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }
        
        let convertedKeyboardFrame = view.convert(keyboardFrame, from: nil)
        let intersection = convertedKeyboardFrame.intersection(view.bounds)
        
        let keyboardHeight = view.bounds.maxY - intersection.minY
        
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
        
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
            filteredDisciplines.removeAll()
            updateData(on: disciplines)
            isSearching = false
            return
        }
        
        isSearching = true
        filteredDisciplines = disciplines.filter { $0.name.lowercased().contains(filter.lowercased()) }
        updateData(on: filteredDisciplines)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        updateData(on: disciplines)
    }
}

extension DisciplineViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        discipline = isSearching ? filteredDisciplines[indexPath.row] : disciplines[indexPath.row]
        searchController.dismiss(animated: true)
        searchBarCancelButtonClicked(searchController.searchBar)
        searchController.searchBar.searchTextField.text = ""
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
}

extension DisciplineViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
}

extension DisciplineViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true)
        }
        
        controller.dismiss(animated: true)
    }
}

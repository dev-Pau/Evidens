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

    private let user: User
    private var viewModel: ShareCaseViewModel

    private var specialities = [Speciality]()
    
    private var specialitiesSelected = [Speciality]()
    private var filteredSpecialities: [Speciality] = []
    
    private var isSearching: Bool = false
    
    private var searchController: UISearchController!
    private let maxCount = 4

    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .label
        button.configuration?.baseForegroundColor = .systemBackground
        button.configuration?.cornerStyle = .capsule
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 18, scaleStyle: .title2, weight: .bold, scales: false)
        button.configuration?.attributedTitle = AttributedString(AppStrings.Miscellaneous.next, attributes: container)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.standardAppearance.shadowColor = separatorColor
        navigationController?.navigationBar.scrollEdgeAppearance?.shadowColor = separatorColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.standardAppearance.shadowColor = .clear
        navigationController?.navigationBar.scrollEdgeAppearance?.shadowColor = .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.disciplines.forEach { discipline in
            specialities.append(contentsOf: discipline.specialities)
        }
 
        configureNavigationBar()
        configureSearchBar()
        configureCollectionView()
        configureDataSource()
        updateData(on: specialities)
    }
    
    init(user: User, viewModel: ShareCaseViewModel) {
        self.user = user
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchController.searchBar.searchTextField.layer.cornerRadius = searchController.searchBar.searchTextField.frame.height / 2
        searchController.searchBar.searchTextField.clipsToBounds = true
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        navigationItem.hidesSearchBarWhenScrolling = false

        let appearance = UINavigationBarAppearance.secondaryAppearance()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationController?.navigationBar.standardAppearance.shadowColor = separatorColor
        navigationController?.navigationBar.scrollEdgeAppearance?.shadowColor = separatorColor
        
        addNavigationBarLogo(withTintColor: primaryColor)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: AppStrings.Global.cancel, style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem?.tintColor = .label
    }
    
    private func configureSearchBar() {
        searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.searchTextField.tintColor = primaryColor
        searchController.searchBar.tintColor = primaryColor
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
        layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        layout.itemSize = CGSize(width: cellWidth, height: fontHeight)
        return layout
    }
    
    private func configureCollectionView() {
        view.backgroundColor = .systemBackground
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createTwoColumnFlowLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.keyboardDismissMode = .onDrag
        collectionView.allowsMultipleSelection = true
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews(collectionView, nextButton)
        collectionView.delegate = self
        collectionView.register(PrimarySpecialityCell.self, forCellWithReuseIdentifier: specialitiesCellReuseIdentifier)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -10),
            
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
        ])
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
    
    @objc func handleDismiss() {
        displayAlert(withTitle: AppStrings.Alerts.Title.cancelContent, withMessage: AppStrings.Alerts.Subtitle.cancelContent, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Alerts.Actions.quit, style: .default) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.dismiss(animated: true)
        }
    }
    
    @objc func handleNext() {
        viewModel.specialities = specialitiesSelected
        
        let controller = ShareCaseKindViewController(user: user, viewModel: viewModel)
        navigationController?.pushViewController(controller, animated: true)
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
        nextButton.isEnabled = true
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let speciality = isSearching ? filteredSpecialities[indexPath.row] : specialities[indexPath.row]
        if let index = specialitiesSelected.firstIndex(where: { $0 == speciality }) {
            specialitiesSelected.remove(at: index)
            if specialitiesSelected.isEmpty { nextButton.isEnabled = false }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if specialitiesSelected.count == 4 {
            return false
        }
        
        return collectionView.indexPathsForSelectedItems!.count <= 4
    }
}

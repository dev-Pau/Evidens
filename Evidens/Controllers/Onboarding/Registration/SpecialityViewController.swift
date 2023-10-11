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
    
    var viewModel: SpecialityViewModel
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Speciality>!
    
    weak var delegate: SpecialityRegistrationViewControllerDelegate?
    
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
    
    private var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureSearchBar()
        configureUI()
        configureData()
        configureCollectionView()
        configureDataSource()
        updateData(on: viewModel.specialities)
    }
    
    init(user: User) {
        self.viewModel = SpecialityViewModel(user: user)
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
        title = viewModel.isEditingProfileSpeciality ? AppStrings.Opening.speciality : ""
        navigationItem.hidesSearchBarWhenScrolling = false

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: viewModel.isEditingProfileSpeciality ? AppStrings.Miscellaneous.change : AppStrings.Miscellaneous.next, style: .done, target: self, action: #selector(handleNext))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        navigationItem.rightBarButtonItem?.isEnabled = false
        addNavigationBarLogo(withTintColor: primaryColor)
    }
    
    private func configureSearchBar() {
        searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = AppStrings.Opening.speciality
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.searchTextField.layer.cornerRadius = 17
        searchController.searchBar.searchTextField.layer.masksToBounds = true
        searchController.searchBar.tintColor = primaryColor
        navigationItem.searchController = searchController
    }
    
    private func configureData() {
        guard let discipline = viewModel.user.discipline else { return }
        viewModel.specialities = discipline.specialities
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.frame = view.bounds
        collectionView.delegate = self
        collectionView.register(RegisterCell.self, forCellWithReuseIdentifier: registerCellReuseIdentifier)
        view.addSubview(collectionView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardFrameChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Speciality>(collectionView: collectionView, cellProvider: { [weak self] collectionView, indexPath, speciality in
            guard let strongSelf = self else { return nil }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: registerCellReuseIdentifier, for: indexPath) as! RegisterCell
            cell.set(value: speciality.name)

            if strongSelf.viewModel.isEditingProfileSpeciality, let userSpeciality = strongSelf.viewModel.user.speciality {
                if speciality == userSpeciality { collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left) }
            }
            
            return cell
        })
    }
    
    private func updateData(on  specialities: [Speciality]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Speciality>()
        snapshot.appendSections([.main])
        snapshot.appendItems(specialities)
        
        
        if let currentSpeciality = viewModel.speciality {
            if snapshot.sectionIdentifier(containingItem: currentSpeciality) == nil {
                snapshot.appendItems([currentSpeciality])
                viewModel.filteredSpecialities.append(currentSpeciality)
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
        if viewModel.isEditingProfileSpeciality {
            guard let speciality = viewModel.speciality else { return }
            delegate?.didEditSpeciality(speciality: speciality)
            navigationController?.popViewController(animated: true)
            return
        }
        
        guard let discipline = viewModel.user.discipline,
              let speciality = viewModel.user.speciality,
              let uid = viewModel.user.uid else { return }
        
        let kind = viewModel.user.kind

        let credentials = AuthCredentials(uid: uid, phase: .details, kind: kind, discipline: discipline, speciality: speciality)

        showProgressIndicator(in: view)
        
        viewModel.setProfessionalDetails(withCredentials: credentials) { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.dismissProgressIndicator()
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            } else {
                strongSelf.viewModel.user.phase = .details
                strongSelf.setUserDefaults(for: strongSelf.viewModel.user)
                let controller = FullNameViewController(user: strongSelf.viewModel.user)
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true)
            }
        }
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

extension SpecialityViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            viewModel.filteredSpecialities.removeAll()
            updateData(on: viewModel.specialities)
            viewModel.isSearching = false
            return
        }
        
        viewModel.isSearching = true
        viewModel.filteredSpecialities = viewModel.specialities.filter { $0.name.lowercased().contains(filter.lowercased()) }
        updateData(on: viewModel.filteredSpecialities)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.isSearching = false
        updateData(on: viewModel.specialities)
    }
}

extension SpecialityViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.speciality = viewModel.isSearching ? viewModel.filteredSpecialities[indexPath.row] : viewModel.specialities[indexPath.row]
        viewModel.user.speciality = viewModel.speciality
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



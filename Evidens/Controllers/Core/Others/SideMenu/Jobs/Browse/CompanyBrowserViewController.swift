//
//  JobBrowseViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/2/23.
//

import UIKit

private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let searchHeaderReuseIdentifier = "SearchHeaderReuseIdentifier"
private let companyEmptyCellReuseIdentifier = "CompanyEmptyCellReuseIdentifier"
private let companyCellReuseIdentifier = "CompanyCellReuseIdentifier"

protocol CompanyBrowserViewControllerDelegate: AnyObject {
    func didSelectCompany(company: Company)
}

class CompanyBrowserViewController: UIViewController {
    weak var delegate: CompanyBrowserViewControllerDelegate?
    
    private var companies = [Company]()
    private var filteredCompanies = [Company]()
    private var companiesLoaded: Bool = false
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureCollectionView()
        fetchCompanies()
    }
    
    private func configureNavigationBar() {
        title = "Companies"
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
    }
    
    private func configureCollectionView() {
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(GroupSearchBarHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier)
        collectionView.register(MESecondaryEmptyCell.self.self, forCellWithReuseIdentifier: companyEmptyCellReuseIdentifier)
        collectionView.register(BrowseCompanyCell.self, forCellWithReuseIdentifier: companyCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func fetchCompanies() {
        CompanyService.fetchCompaniesDocuments { snapshot in
            let documents = snapshot.documents
            if documents.isEmpty {
                self.companiesLoaded = true
                self.collectionView.reloadData()
            } else {
                self.companies = documents.map({ Company(dictionary: $0.data()) })
                self.filteredCompanies = self.companies
                self.companiesLoaded = true
                self.collectionView.reloadData()
            }
        }
    }
}

extension CompanyBrowserViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            if companiesLoaded && companies.isEmpty { return CGSize.zero }
            return CGSize(width: UIScreen.main.bounds.width, height: 55)
        }
        
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return 0 }
        return companiesLoaded ? filteredCompanies.isEmpty ? 1 : filteredCompanies.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if !companiesLoaded {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
            return header
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier, for: indexPath) as! GroupSearchBarHeader
            header.setSearchBarPlaceholder(text: "Search companies")
            header.invalidateInstantSearch = true
            header.delegate = self
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if companies.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: companyEmptyCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
            cell.configure(image: UIImage(named: "content.empty"), title: "No companies found.", description: "Check back later for new companies or create your own.", buttonText: .dismiss)
            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: companyCellReuseIdentifier, for: indexPath) as! BrowseCompanyCell
            cell.company = filteredCompanies[indexPath.row]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return companies.isEmpty ? CGSize(width: view.frame.width, height: view.frame.height * 0.7) : CGSize(width: UIScreen.main.bounds.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !filteredCompanies.isEmpty else { return }
        delegate?.didSelectCompany(company: filteredCompanies[indexPath.row])
        navigationController?.popViewController(animated: true)
    }
}

extension CompanyBrowserViewController: GroupSearchBarHeaderDelegate {
    func didSearchText(text: String) {
        CompanyService.searchCompanyWithText(text: text.trimmingCharacters(in: .whitespaces)) { companies in
            self.filteredCompanies = companies
            self.collectionView.reloadSections(IndexSet(integer: 1))
        }
    }
    
    func resetUsers() {
        filteredCompanies = companies
        collectionView.reloadSections(IndexSet(integer: 1))
    }
}

extension CompanyBrowserViewController: MESecondaryEmptyCellDelegate {
    func didTapEmptyCellButton(option: EmptyCellButtonOptions) {
        navigationController?.popViewController(animated: true)
    }
}

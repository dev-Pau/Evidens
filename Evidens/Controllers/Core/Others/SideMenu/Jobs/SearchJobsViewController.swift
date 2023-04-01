//
//  SearchJobsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 29/3/23.
//

import UIKit
import Firebase

private let loadingSearchHeaderReuseIdentifier = "LoadingSearchHeaderReuseIdentifier"
private let emptyContentCellReuseIdentifier = "EmptyContentCellReuseIdentifier"
private let searchRecentsHeaderReuseIdentifier = "SearchRecentsHeaderReuseIdentifier"
private let emptySearchResultsReuseIdentifier = "EmptySearchResultsReuseIdentifier"
private let recentContentSearchReuseIdentifier = "RecentContentSearchReuseIdentifier"
private let jobCellReuseIdentifier = "JobCellReuseIdentifier"

/*
protocol SearchConversationViewControllerDelegate: AnyObject {
    func didTapUser(user: User)
    func updatePan()
    func didTapTextToSearch(text: String)
    func filterConversationsWithText(text: String, completion: @escaping([User]) -> Void)
}
*/

protocol SearchJobsViewControllerDelegate: AnyObject {
    func didTapTextToSearch(text: String)
    func didBookmarkJob(job: Job)
}

class SearchJobsViewController: UIViewController {
    
    weak var delegate: SearchJobsViewControllerDelegate?
    
    private var user: User
    private var recentSearches = [String]()
    private var companies = [Company]()
    private var jobs = [Job]()
    private var lastJobSnapshot: QueryDocumentSnapshot?
    //private var filteredUsers = []()
    private var searchedText: String = ""
    private var arraySearchedText = [String]()
    
    private var dataLoaded: Bool = false
    private var isInSearchMode: Bool = false
    
    private var collectionView: UICollectionView!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureCollectionView()
        configureUI()
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !dataLoaded { fetchRecentJobSearches() }
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env -> NSCollectionLayoutSection? in
            if self.isInSearchMode {
                // Job Search
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(55))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
                
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: self.jobs.count == 0 ? .fractionalHeight(1) : .estimated(65)))
                
                item.contentInsets.leading = 10
                item.contentInsets.trailing = 10
                
                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: self.jobs.count == 0 ? .fractionalHeight(0.9) : .estimated(65)), subitems: [item])
              
                let section = NSCollectionLayoutSection(group: group)
                if !self.dataLoaded { section.boundarySupplementaryItems = [header] }
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
                
                return section
                
            } else {
                // Recents
                    let recentsIsEmpty = self.recentSearches.isEmpty
                    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40))
                    let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
                
                    let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), subitems: [item])
                    
                    let section = NSCollectionLayoutSection(group: group)
                    section.interGroupSpacing = 0
                    if !recentsIsEmpty { section.boundarySupplementaryItems = [header] }
                    
                    return section
                }
            }
        return layout
    }
    
    private func fetchRecentJobSearches() {
        DatabaseManager.shared.fetchRecentJobSearches { result in
            switch result {
            case .success(let searches):
                guard !searches.isEmpty else {
                    self.dataLoaded = true
                    self.collectionView.reloadData()
                    return
                }
                
                self.recentSearches = searches
                self.dataLoaded = true
                self.collectionView.reloadData()
                
            case .failure(_):
                print("error fetching recent messages")
            }
        }
    }

    func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.keyboardDismissMode = .onDrag
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.frame = view.bounds

        collectionView.register(MEPrimaryEmptyCell.self, forCellWithReuseIdentifier: emptySearchResultsReuseIdentifier)
        collectionView.register(EmptyRecentsSearchCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        collectionView.register(SearchRecentsHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: searchRecentsHeaderReuseIdentifier)
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingSearchHeaderReuseIdentifier)
        collectionView.register(RecentContentSearchCell.self, forCellWithReuseIdentifier: recentContentSearchReuseIdentifier)

        collectionView.register(BrowseJobCell.self, forCellWithReuseIdentifier: jobCellReuseIdentifier)
    }
    
    func configureUI() {
        view.backgroundColor = .systemBackground
    }
    
    @objc func fetchJobsWithSearchedText(_ searchedText: [String]) {
        jobs.removeAll()
        companies.removeAll()
        JobService.fetchJobsWithText(searchedText, lastSnapshot: nil) { snapshot in
            guard !snapshot.isEmpty else {
                self.dataLoaded = true
                self.collectionView.reloadData()
                return
            }
            
            self.lastJobSnapshot = snapshot.documents.last
            let jobs = snapshot.documents.map({ Job(jobId: $0.documentID, dictionary: $0.data()) })
            JobService.fetchJobValuesFor(jobs: jobs) { jobsWithValues in
                self.jobs = jobsWithValues
                let companyIds = self.jobs.map { $0.companyId }
                CompanyService.fetchCompanies(withIds: companyIds) { companies in
                    self.companies = companies
                    self.dataLoaded = true
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            getMoreJobs()
        }
    }
    
    private func getMoreJobs() {
        guard !arraySearchedText.isEmpty else { return }
        JobService.fetchJobsWithText(arraySearchedText, lastSnapshot: lastJobSnapshot) { snapshot in
            guard !snapshot.isEmpty else { return }
            self.lastJobSnapshot = snapshot.documents.last
            let newJobs = snapshot.documents.map({ Job(jobId: $0.documentID, dictionary: $0.data()) })
            JobService.fetchJobValuesFor(jobs: newJobs) { newJobsWithValues in
                self.jobs.append(contentsOf: newJobsWithValues)
                let companyIds = self.jobs.map { $0.companyId }
                CompanyService.fetchCompanies(withIds: companyIds) { companies in
                    self.companies.append(contentsOf: companies)
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

extension SearchJobsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !isInSearchMode {
            return dataLoaded ? recentSearches.isEmpty ? 1 : recentSearches.count : 0
        } else {
            return dataLoaded ? jobs.isEmpty ? 1 : jobs.count : 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if !dataLoaded {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingSearchHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
            return header
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: searchRecentsHeaderReuseIdentifier, for: indexPath) as! SearchRecentsHeader
            header.delegate = self
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if !isInSearchMode {
            return recentSearches.isEmpty ? CGSize.zero : CGSize(width: view.frame.width, height: 40)
        } else {
            return dataLoaded ? CGSize.zero : CGSize(width: view.frame.width, height: 40)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if !isInSearchMode {
            if recentSearches.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! EmptyRecentsSearchCell
                cell.set(title: "Try searching for job titles")
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: recentContentSearchReuseIdentifier, for: indexPath) as! RecentContentSearchCell
                cell.viewModel = RecentTextCellViewModel(recentText: recentSearches[indexPath.row])
                return cell
            }
        } else {
            if jobs.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptySearchResultsReuseIdentifier, for: indexPath) as! MEPrimaryEmptyCell
                cell.set(withImage: UIImage(named: "message.empty")!, withTitle: "No results for \"\(searchedText)\"", withDescription: "The term you entered did not bring up any results. You may want to try using different search terms.", withButtonText: "   Remove filters   ")
                cell.delegate = self
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: jobCellReuseIdentifier, for: indexPath) as! BrowseJobCell
                cell.viewModel = JobViewModel(job: jobs[indexPath.row])
                cell.delegate = self
                if let companyIndex = companies.firstIndex(where: { $0.id == jobs[indexPath.row].companyId }) {
                    cell.configureWithCompany(company: companies[companyIndex])
                }
                return cell
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isInSearchMode {
            guard !recentSearches.isEmpty else { return }
            let searchedText = recentSearches[indexPath.row]
            isInSearchMode = true
            dataLoaded = false
            collectionView.reloadData()
            formatTextToSearch(searchText: searchedText)
            delegate?.didTapTextToSearch(text: searchedText)
        } else {
            guard !jobs.isEmpty else { return }
            if let companyIndex = companies.firstIndex(where: { $0.id == jobs[indexPath.row].companyId }) {
                let controller = JobDetailsViewController(job: jobs[indexPath.row], company: companies[companyIndex], user: user)
                controller.delegate = self
                let navController = UINavigationController(rootViewController: controller)
                navController.modalPresentationStyle = .fullScreen
                present(navController, animated: true)
            }
        }
    }
}

extension SearchJobsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        DatabaseManager.shared.uploadRecentJobsSearches(with: searchText) { _ in }
        recentSearches.insert(searchText, at: 0)
        isInSearchMode = true
        searchedText = searchText
        dataLoaded = false
        collectionView.reloadData()
        formatTextToSearch(searchText: searchText)
        
        /*
        delegate?.filterConversationsWithText(text: searchText.lowercased(), completion: { users in
            #warning("We also need to search for messages")
            self.filteredUsers = users
            self.dataLoaded = true
            self.collectionView.reloadData()
        })
         */
    }
    
    func formatTextToSearch(searchText: String) {
        let trimmedText = searchText.trimmingCharacters(in: .whitespaces)
        let arrayTextToSearch = trimmedText.split(separator: " ").map({ $0.lowercased() }).map({ $0.capitalized })
        arraySearchedText = arrayTextToSearch
        fetchJobsWithSearchedText(arraySearchedText)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            isInSearchMode = false
            dataLoaded = true
            collectionView.reloadData()
            return
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //delegate?.updatePan()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //delegate?.updatePan()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.searchTextField.resignFirstResponder()
        isInSearchMode = false
        dataLoaded = true
        collectionView.reloadData()
    }
}

extension SearchJobsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        /*
        guard let text = searchController.searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            if !dataLoaded { return }
            isInSearchMode = false
            dataLoaded = true
            self.collectionView.reloadData()
            return
        }
         */
    }
}

extension SearchJobsViewController: SearchRecentsHeaderDelegate {
    func didTapClearSearches() {
        displayMEDestructiveAlert(withTitle: "Delete recent searches", withMessage: "Are you sure you want to clear your most job recent searches?", withCancelButtonText: "Cancel", withDoneButtonText: "Delete") {
            DatabaseManager.shared.deleteRecentMessageSearches { result in
                switch result {
                case .success(_):
                    self.recentSearches.removeAll()
                    self.collectionView.reloadData()
                case .failure(_):
                    print("could not delete recent messages due to error")
                }
            }
        }
    }
}

extension SearchJobsViewController: BrowseJobCellDelegate {
    func didBookmarkJob(_ cell: UICollectionViewCell, job: Job) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        HapticsManager.shared.vibrate(for: .success)
        switch cell {
        case is BrowseJobCell:
            let currentCell = cell as! BrowseJobCell
            currentCell.viewModel?.job.didBookmark.toggle()
            
            if job.didBookmark {
                JobService.unbookmarkJob(job: job) { _ in
                    self.jobs[indexPath.row].didBookmark = false
                    currentCell.isUpdatingJoiningState = false
                    self.delegate?.didBookmarkJob(job: job)
                }
            } else {
                JobService.bookmarkJob(job: job) { _ in
                    self.jobs[indexPath.row].didBookmark = true
                    currentCell.isUpdatingJoiningState = false
                    self.delegate?.didBookmarkJob(job: job)
                }
            }
            
        default:
            print("No cell registered for this type")
        }
    }
}

extension SearchJobsViewController: JobDetailsViewControllerDelegate {
    func didBookmark(job: Job, company: Company) {
        if let jobIndex = jobs.firstIndex(where: { $0.jobId == job.jobId }) {
            jobs[jobIndex].didBookmark.toggle()
            collectionView.reloadItems(at: [IndexPath(item: jobIndex, section: 0)])
            delegate?.didBookmarkJob(job: job)
        }
    }
}

extension SearchJobsViewController: EmptyGroupCellDelegate {
    
    func didTapDiscoverGroup() {
        isInSearchMode = false
        dataLoaded = true
        collectionView.reloadData()
        delegate?.didTapTextToSearch(text: "")
        return
    }
}


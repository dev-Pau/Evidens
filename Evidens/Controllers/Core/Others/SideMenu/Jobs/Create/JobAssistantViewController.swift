//
//  JobAssistantViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/2/23.
//

import UIKit

private let jobTypeCellReuseIdentifier = "JobTypeCellReuseIdentifier"

protocol JobAssistantViewControllerDelegate: AnyObject {
    func didSelectItem(_ text: String)
}

protocol JobAssistantMultipleViewControllerDelegate: AnyObject {
    func didSelectItems(_ text: [String])
}



class JobAssistantViewController: UIViewController {
    weak var delegate: JobAssistantViewControllerDelegate?
    weak var multipleDelegate: JobAssistantMultipleViewControllerDelegate?
   
    private var jobSection: Job.JobSections
    
    private var dataSource = [String]()
    
    var allowsMultipleSelection: Bool = false
    var selectedProfessions = [String]()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search location"
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
    }
    
    init(jobSection: Job.JobSections) {
        self.jobSection = jobSection
        
        switch jobSection {
        case .title:
            break
        case .description:
            break
        case .workplace:
            dataSource = Job.WorksplaceType.allCases.map({ $0.rawValue })
        case .location:
            break
        case .type:
            dataSource = Job.JobType.allCases.map({ $0.rawValue })
        case .professions:
            dataSource = Profession.getAllProfessions().map({ $0.profession })
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        switch jobSection {
        case .title:
            break
        case .description:
            break
        case .workplace:
            title = "Worksplace"
        case .location:
            title = "Location"
        case .type:
            title = "Type"
        case .professions:
            title = "Profession"
        }
    }
    
    private func configureCollectionView() {
        view.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ClinicalTypeCell.self, forCellWithReuseIdentifier: jobTypeCellReuseIdentifier)
        if jobSection == .title {
            #warning("search all industries and put it here, bow we have job type just to search if it works")
            //dataSource = Company.AllIndustry()
            dataSource = ["Clinical Liaison",
                          "Clinical Nurse Manager",
                          "Clinical Research Associate",
                          "Clinical Research Coordinator",
                          "Clinical Reviewer",
                          "Clinical Specialist"]
        }
        
        if jobSection == .professions && allowsMultipleSelection {
            collectionView.allowsSelection = true
            collectionView.allowsMultipleSelection = true
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(handleAddProfessions))
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
       
        if jobSection == .location {
            searchBar.delegate = self
            
            view.addSubviews(searchBar, collectionView)
            NSLayoutConstraint.activate([
                searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                
                collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
                collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        } else {
            view.addSubview(collectionView)
            collectionView.frame = view.bounds
        }
    }
    
    @objc func handleAddProfessions() {
        guard !selectedProfessions.isEmpty else { return }
        multipleDelegate?.didSelectItems(selectedProfessions)
        navigationController?.popViewController(animated: true)
    }
}


extension JobAssistantViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: jobTypeCellReuseIdentifier, for: indexPath) as! ClinicalTypeCell
        cell.set(title: dataSource[indexPath.row])
        if selectedProfessions.contains(dataSource[indexPath.row]) {
            collectionView.selectItem(at: IndexPath(item: indexPath.row, section: 0), animated: false, scrollPosition: .left)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 45)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard dataSource.count > 0 else { return }
        
        if jobSection == .professions && allowsMultipleSelection {
            selectedProfessions.append(dataSource[indexPath.row])
            navigationItem.rightBarButtonItem?.isEnabled = selectedProfessions.isEmpty ? false : true
        } else {
            delegate?.didSelectItem(dataSource[indexPath.row])
            navigationController?.popViewController(animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if jobSection == .professions && allowsMultipleSelection {
            if let professionIndex = selectedProfessions.firstIndex(where: { $0 == dataSource[indexPath.row] }) {
                selectedProfessions.remove(at: professionIndex)
                navigationItem.rightBarButtonItem?.isEnabled = selectedProfessions.isEmpty ? false : true
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if jobSection == .professions && allowsMultipleSelection {
            return selectedProfessions.count < 3 ? true : false
        } else {
            return true
        }
    }
}

extension JobAssistantViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else { return }
        LocationService.findLocations(with: text) { location in
            self.dataSource = location.map({ $0.name })
            self.collectionView.reloadData()
        }
    }
}

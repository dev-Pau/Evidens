//
//  ShareCaseProfessionsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/5/23.
//

import UIKit

private let interestsRegistrationHeaderReuseIdentifier = "InterestsHeaderReuseIdentifier"
private let filterCellReuseIdentifier = "FilterCellReuseIdentifier"
private let interestsSectionTitleReuseIdentifier = "InterestsSectionTitleReuseIdentifier"

class ShareCaseProfessionsViewController: UIViewController {
    
    private var user: User
    private var group: Group?
    private var collectionView: UICollectionView!
    
    private var allProfessions = [String]()
    
    private var selectedProfessions = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureCollectionView()
    }

    init(user: User, group: Group? = nil) {
        self.user = user
        #warning("aixo s'ha cambiat tb")
        allProfessions = Discipline.allCases.map { $0.name }.filter({ $0 != user.profession! })
        //Profession.getAllProfessions().map({ $0.profession }).filter({ $0 != user.profession! })
        allProfessions.insert(user.profession!, at: 0)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = "Share Case"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(handleAdd))
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.leftBarButtonItem?.tintColor = .label
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.register(InterestsRegistrationHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: interestsRegistrationHeaderReuseIdentifier)
        collectionView.register(RegistrationInterestsCell.self, forCellWithReuseIdentifier: filterCellReuseIdentifier)
        collectionView.register(SecondarySearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: interestsSectionTitleReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        view.addSubview(collectionView)
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)

            
            let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(320), heightDimension: .absolute(40))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(30)), subitems: [item])
            group.interItemSpacing = NSCollectionLayoutSpacing.fixed(10)
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 15, trailing: 10)
            section.interGroupSpacing = 10
            
            section.boundarySupplementaryItems = [header]

            return section
        }
        
        return layout
    }
    
    @objc func handleAdd() {
        let controller = ShareCaseViewController(user: user, group: group)
        controller.viewModel.professions = selectedProfessions
        navigationItem.backBarButtonItem = nil
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func checkIfUserSelectedProfessions() {
        navigationItem.rightBarButtonItem?.isEnabled = selectedProfessions.isEmpty ? false : true
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}

extension ShareCaseProfessionsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else {
            return allProfessions.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: filterCellReuseIdentifier, for: indexPath) as! RegistrationInterestsCell
        cell.setText(text: allProfessions[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == 0 {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: interestsRegistrationHeaderReuseIdentifier, for: indexPath) as! InterestsRegistrationHeader
            header.setTitle(text: "Assign categories.", description: "By assigning appropriate categories, you can ensure easier navigation, effective search, and better collaboration within the healthcare community. Select the most appropriate categories that align with the characteristics and aspects of this case, empowering professionals to access and contribute valuable insights and expertise.")
            return header
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: interestsSectionTitleReuseIdentifier, for: indexPath) as! SecondarySearchHeader
            header.configureWith(title: "Select all that apply", linkText: "")
            header.hideSeeAllButton()
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return selectedProfessions.count < 3 ? true : false
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedProfessions.append(allProfessions[indexPath.row])
        checkIfUserSelectedProfessions()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let professionIndex = selectedProfessions.firstIndex(where: { $0 == allProfessions[indexPath.row] }) {
            selectedProfessions.remove(at: professionIndex)
            checkIfUserSelectedProfessions()
        }
    }
}

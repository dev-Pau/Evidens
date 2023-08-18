//
//  ShareCaseDisciplinesViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/5/23.
//

import UIKit

private let interestsRegistrationHeaderReuseIdentifier = "InterestsHeaderReuseIdentifier"
private let filterCellReuseIdentifier = "FilterCellReuseIdentifier"
private let interestsSectionTitleReuseIdentifier = "InterestsSectionTitleReuseIdentifier"

class ShareCaseDisciplinesViewController: UIViewController {
    
    private var user: User
    private var collectionView: UICollectionView!
    
    private var disciplines = [Discipline]()
    private var selectedDisciplines = [Discipline]()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureCollectionView()
    }

    init(user: User) {
        self.user = user
        disciplines = Discipline.allCases.map { $0 }.filter { $0 != user.discipline }
        disciplines.insert(user.discipline!, at: 0)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance.secondaryAppearance()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        addNavigationBarLogo(withTintColor: primaryColor)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: AppStrings.Miscellaneous.next, style: .done, target: self, action: #selector(handleAdd))
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: AppStrings.Global.cancel, style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.leftBarButtonItem?.tintColor = .label
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.register(ContentHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: interestsRegistrationHeaderReuseIdentifier)
        collectionView.register(ChoiceCell.self, forCellWithReuseIdentifier: filterCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        view.addSubview(collectionView)
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let _ = self else { return nil }
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)

            
            let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(320), heightDimension: .absolute(40))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(30)), subitems: [item])
            group.interItemSpacing = NSCollectionLayoutSpacing.fixed(10)
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 10, bottom: 15, trailing: 10)
            section.interGroupSpacing = 10
            
            if sectionNumber == 0 {
                section.boundarySupplementaryItems = [header]
            }
        
            return section
        }
        
        return layout
    }
    
    @objc func handleAdd() {
        var viewModel = ShareCaseViewModel()
        viewModel.set(disciplines: selectedDisciplines)
        
        let controller = ShareCaseViewController(user: user, viewModel: viewModel)
        navigationItem.backBarButtonItem = nil
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func checkIfUserSelectedProfessions() {
        navigationItem.rightBarButtonItem?.isEnabled = selectedDisciplines.isEmpty ? false : true
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}

extension ShareCaseDisciplinesViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 0 : disciplines.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: filterCellReuseIdentifier, for: indexPath) as! ChoiceCell
        cell.set(discipline: disciplines[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: interestsRegistrationHeaderReuseIdentifier, for: indexPath) as! ContentHeader
        header.configure(withTitle: AppStrings.Content.Case.Share.shareTitle, withContent: AppStrings.Content.Case.Share.shareContent)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return selectedDisciplines.count < 3 ? true : false
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedDisciplines.append(disciplines[indexPath.row])
        checkIfUserSelectedProfessions()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let professionIndex = selectedDisciplines.firstIndex(where: { $0 == disciplines[indexPath.row] }) {
            selectedDisciplines.remove(at: professionIndex)
            checkIfUserSelectedProfessions()
        }
    }
}

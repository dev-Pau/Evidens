//
//  TopicsInterestViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/3/23.
//

import UIKit

private let interestsRegistrationHeaderReuseIdentifier = "InterestsHeaderReuseIdentifier"
private let filterCellReuseIdentifier = "FilterCellReuseIdentifier"
private let interestsSectionTitleReuseIdentifier = "InterestsSectionTitleReuseIdentifier"

class InterestsViewController: UIViewController {
    
    private var user: User
    private var collectionView: UICollectionView!
    
    private var allProfessions = [String]()
    
    private var selectedProfessions = [String]()
    


    private lazy var skipLabel: UILabel = {
        let label = UILabel()
        label.text = "Skip for now"
        label.sizeToFit()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .bold)
        let textRange = NSRange(location: 0, length: label.text!.count)
        let attributedText = NSMutableAttributedString(string: label.text!)
        attributedText.addAttribute(.underlineStyle,
                                    value: NSUnderlineStyle.single.rawValue,
                                    range: textRange)
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSkip)))
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureCollectionView()
    }

    init(user: User) {
        self.user = user
        allProfessions = Profession.getAllProfessions().map({ $0.profession }).filter({ $0 != user.profession! })
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = "Interests"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(handleAdd))
        navigationItem.rightBarButtonItem?.isEnabled = false
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
        view.addSubviews(collectionView, skipLabel)
        NSLayoutConstraint.activate([
            skipLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            skipLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            skipLabel.widthAnchor.constraint(equalToConstant: 150),
        ])
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
        user.interests = selectedProfessions
        
        let controller = ImageRegistrationViewController(user: user)
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleSkip() {
        let controller = ImageRegistrationViewController(user: user)
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func checkIfUserSelectedProfessions() {
        navigationItem.rightBarButtonItem?.isEnabled = selectedProfessions.isEmpty ? false : true
    }
}

extension InterestsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
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
            header.setTitle(text: "What are your interests?", description: "Besides \(user.profession!), what are your interests?. Interests are used to personalize your experience and will not be visible or shared on your profile.")
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


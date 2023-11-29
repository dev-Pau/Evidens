//
//  TopicsInterestViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/3/23.
//

import UIKit

private let contentHeaderReuseIdentifier = "ContentHeaderReuseIdentifier"
private let choiceCellReuseIdentifier = "FilterCellReuseIdentifier"
private let choiceHeaderReuseIdentifier = "ChoiceHeaderReuseIdentifier"

class HobbiesViewController: UIViewController {
    
    private var user: User
    private var collectionView: UICollectionView!
    
    private var disciplines = [Discipline]()
    
    private var selectedDisciplines = [Discipline]()
    
    private lazy var skipLabel: UILabel = {
        let label = UILabel()
        label.text = AppStrings.Global.skip
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
        configure()
        configureCollectionView()
    }

    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: AppStrings.Global.add, style: .done, target: self, action: #selector(handleAdd))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        navigationItem.rightBarButtonItem?.isEnabled = false
        addNavigationBarLogo(withTintColor: primaryColor)
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        guard let discipline = user.discipline else {
            fatalError()
        }
        disciplines = Discipline.allCases.filter { $0 != discipline }
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.register(ContentHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: contentHeaderReuseIdentifier)
        collectionView.register(ChoiceCell.self, forCellWithReuseIdentifier: choiceCellReuseIdentifier)
        collectionView.register(SecondarySearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: choiceHeaderReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        skipLabel.backgroundColor = .systemBackground
        view.addSubviews(collectionView, skipLabel)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: skipLabel.topAnchor, constant: -20),
            
            skipLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            skipLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            skipLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            skipLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let _ = self else { return nil }
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)

            let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(320), heightDimension: .estimated(100))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)), subitems: [item])
            group.interItemSpacing = NSCollectionLayoutSpacing.fixed(10)
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: sectionNumber == 0 ? 0 : 10, leading: sectionNumber == 0 ? 10 : 20, bottom: 0, trailing: sectionNumber == 0 ? 10 : 20)
            section.interGroupSpacing = 10
            if sectionNumber == 0 {
                section.boundarySupplementaryItems = [header]
            }

            return section
        }
        
        return layout
    }
    
    @objc func handleAdd() {
        user.hobbies = selectedDisciplines
        let controller = ImageViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleSkip() {
        let controller = ImageViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func checkHobbieCount() {
        navigationItem.rightBarButtonItem?.isEnabled = selectedDisciplines.isEmpty ? false : true
    }
}

extension HobbiesViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 0 : disciplines.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: choiceCellReuseIdentifier, for: indexPath) as! ChoiceCell
        cell.set(discipline: disciplines[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: contentHeaderReuseIdentifier, for: indexPath) as! ContentHeader
        header.configure(withTitle: AppStrings.Profile.interests, withContent: AppStrings.Profile.interestsContent(withDiscipline: user.discipline!))
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return selectedDisciplines.count < 3 ? true : false
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedDisciplines.append(disciplines[indexPath.row])
        checkHobbieCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let index = selectedDisciplines.firstIndex(where: { $0 == disciplines[indexPath.row] }) {
            selectedDisciplines.remove(at: index)
            checkHobbieCount()
        }
    }
}


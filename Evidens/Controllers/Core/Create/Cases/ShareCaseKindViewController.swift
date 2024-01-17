//
//  ShareCaseKindViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/12/23.
//

import UIKit

let contentHeaderReuseIdentifier = "ContentHeaderReuseIdentifier"
let kindCellReuseIdentifier = "KindCellReuseIdentifier"

class ShareCaseKindViewController: UIViewController {
    
    private let user: User
    private var viewModel: ShareCaseViewModel
    
    private var collectionView: UICollectionView!
    
    private var selectedItems = [CaseItem]()

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
    
    init(user: User, viewModel: ShareCaseViewModel) {
        self.user = user
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure()
    }
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance.secondaryAppearance()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        addNavigationBarLogo(withTintColor: primaryColor)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: AppStrings.Global.cancel, style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem?.tintColor = .label
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ContentHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: contentHeaderReuseIdentifier)
        collectionView.register(RegisterCell.self, forCellWithReuseIdentifier: kindCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        
        view.addSubviews(collectionView, nextButton)
        
        NSLayoutConstraint.activate([
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -10)
        ])
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let _ = self else { return nil }
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(40))
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
            group.interItemSpacing = NSCollectionLayoutSpacing.fixed(10)
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 10, bottom: 0, trailing: 10)
            section.interGroupSpacing = 10
            
            section.boundarySupplementaryItems = [header]
            
            return section
        }
        
        return layout
    }
    
    private func checkIfKindSelected() {
        nextButton.isEnabled = !selectedItems.isEmpty
    }
    
    @objc func handleDismiss() {
        displayAlert(withTitle: AppStrings.Alerts.Title.cancelContent, withMessage: AppStrings.Alerts.Subtitle.cancelContent, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Alerts.Actions.quit, style: .default) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.dismiss(animated: true)
        }
    }
    
    @objc func handleNext() {
        guard !selectedItems.isEmpty else { return }
        viewModel.items = selectedItems
        
        let controller = ShareCaseStageViewController(user: user, viewModel: viewModel)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension ShareCaseKindViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CaseItem.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kindCellReuseIdentifier, for: indexPath) as! RegisterCell
        cell.set(item: CaseItem.allCases[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: contentHeaderReuseIdentifier, for: indexPath) as! ContentHeader
        header.configure(withTitle: AppStrings.Content.Case.Share.caseTraitsTitle, withContent: AppStrings.Content.Case.Share.caseTraitsContent)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return selectedItems.count < 3 ? true : false
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedItems.append(CaseItem.allCases[indexPath.row])
        checkIfKindSelected()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let itemIndex = selectedItems.firstIndex(where: { $0 == CaseItem.allCases[indexPath.row] }) {
            selectedItems.remove(at: itemIndex)
            checkIfKindSelected()
        }
    }
}


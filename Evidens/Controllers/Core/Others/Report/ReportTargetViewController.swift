//
//  ReportTargetViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/4/23.
//

import UIKit

private let reportHeaderReuseIdentifier = "ReportHeaderReuseIdentifier"
private let reportCellReuseIdentifier = "ReportCellReuseIdentifier"

class ReportTargetViewController: UIViewController {
    
    private var viewModel: ReportViewModel
    private var collectionView: UICollectionView!
    
    private lazy var reportButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .label
        button.configuration?.baseForegroundColor = .systemBackground
        button.configuration?.cornerStyle = .capsule
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 18, weight: .bold)
        button.configuration?.attributedTitle = AttributedString(AppStrings.Miscellaneous.next, attributes: container)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleContinueReport), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
    }
    
    
    init(viewModel: ReportViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        addNavigationBarLogo(withImage: AppStrings.Assets.blackLogo, withTintColor: primaryColor)
    }
    
    private func configureUI() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        view.addSubview(collectionView)
        view.backgroundColor = .systemBackground
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ReportHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: reportHeaderReuseIdentifier)
        collectionView.register(ReportTargetCell.self, forCellWithReuseIdentifier: reportCellReuseIdentifier)
        collectionView.allowsMultipleSelection = false
        
        view.addSubviews(reportButton, collectionView)
        NSLayoutConstraint.activate([
            reportButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            reportButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            reportButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            reportButton.heightAnchor.constraint(equalToConstant: 50),
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: reportButton.topAnchor, constant: -10)
        ])
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [header]
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
    
    @objc func handleContinueReport() {
        let controller = ReportTopicViewController(viewModel: viewModel)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension ReportTargetViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ReportTarget.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reportHeaderReuseIdentifier, for: indexPath) as! ReportHeader
        header.configure(withTitle: AppStrings.Report.Target.title, withDescription: AppStrings.Report.Target.content)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reportCellReuseIdentifier, for: indexPath) as! ReportTargetCell
        cell.configure(withTitle: ReportTarget.allCases[indexPath.row].title, withDescription: ReportTarget.allCases[indexPath.row].content)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.edit(target: ReportTarget.allCases[indexPath.row])
        reportButton.isEnabled = true
    }
}

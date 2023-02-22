//
//  JobDetailsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/2/23.
//

import UIKit

private let jobHeaderCellReuseIdentifier = "JobHeaderCellReuseIdentifier"

class JobDetailsViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    
    private let applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = primaryColor
        button.configuration?.baseForegroundColor = .white
        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("  Apply  ", attributes: container)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .systemBackground
        button.configuration?.baseForegroundColor = .secondaryLabel
        button.configuration?.cornerStyle = .capsule
        button.configuration?.background.strokeColor = .secondaryLabel
        button.configuration?.background.strokeWidth = 1
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("  Save  ", attributes: container)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var job: Job
    private var company: Company
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureNavigationBar()
    }
    
    
    init(job: Job, company: Company) {
        self.job = job
        self.company = company
        super.init(nibName: nil, bundle: nil)
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(JobHeaderCell.self, forCellWithReuseIdentifier: jobHeaderCellReuseIdentifier)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "kek")
        
        view.addSubviews(collectionView, saveButton, applyButton)
        NSLayoutConstraint.activate([
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
            applyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            applyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
      
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 0
        config.scrollDirection = .horizontal
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func configureNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}

extension JobDetailsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: jobHeaderCellReuseIdentifier, for: indexPath) as! JobHeaderCell
            cell.viewModel = JobViewModel(job: job)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "kek", for: indexPath)
            cell.backgroundColor = .systemPink
            return cell
        }

    }
}

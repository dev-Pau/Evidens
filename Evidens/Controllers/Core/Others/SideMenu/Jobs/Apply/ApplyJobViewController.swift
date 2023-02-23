//
//  ApplyJobViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/2/23.
//

import UIKit

private let applyJobHeaderReuseIdentifier = "ApplyJobHeaderReuseIdentifier"
private let jobAttachementsCellReuseIdentifier = "JobAttachementsCellReuseIdentifier"

class ApplyJobViewController: UIViewController {
    private var job: Job
    private var company: Company
    private var user: User
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 200)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = primaryColor
        button.configuration?.baseForegroundColor = .white
        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("  Apply  ", attributes: container)
        button.addTarget(self, action: #selector(handleApplyJob), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.borderColor = UIColor.quaternarySystemFill.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    init(job: Job, company: Company, user: User) {
        self.user = user
        self.job = job
        self.company = company
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureNavigationBar()
    }
    
    private func configureCollectionView() {
        view.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ApplyJobHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: applyJobHeaderReuseIdentifier)
        collectionView.register(JobAttachementsCell.self, forCellWithReuseIdentifier: jobAttachementsCellReuseIdentifier)
        
        view.addSubviews(collectionView, bottomView, applyButton)
        NSLayoutConstraint.activate([
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 80),
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomView.topAnchor),
            
            applyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            applyButton.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 5),
        ])
        
        applyButton.isEnabled = false
    }

    private func configureNavigationBar() {
        title = "Apply"
    }
    
    @objc func handleApplyJob() {
        
    }
}

extension ApplyJobViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: applyJobHeaderReuseIdentifier, for: indexPath) as! ApplyJobHeader
        header.user = user
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 160)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: jobAttachementsCellReuseIdentifier, for: indexPath) as! JobAttachementsCell
        return cell
    }
}

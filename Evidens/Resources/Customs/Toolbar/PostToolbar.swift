//
//  PostAssistantToolbar.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/4/23.
//

import UIKit

private let postDisciplinesCellReuseIdentifier = "PostDisciplinesCellReuseIdentifier"

protocol PostToolbarDelegate: AnyObject {
    func didTapAddMediaButton()
    func didTapQuoteButton()
    func didTapConfigureDisciplines()
}

class PostToolbar: UIToolbar {
    
    weak var toolbarDelegate: PostToolbarDelegate?
    private var collectionView: UICollectionView!
    private var disciplines: [Discipline]
    
    private lazy var addMediaButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.buttonSize = .mini
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.plus, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.systemBackground).scalePreservingAspectRatio(targetSize: CGSize(width: 12, height: 12))
        button.configuration?.baseBackgroundColor = primaryColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleAddMediaButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var addReferenceButton: UIButton = {
        let button = UIButton()
        button.configuration = .plain()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.buttonSize = .mini
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.fillHeart)?.withRenderingMode(.alwaysOriginal).withTintColor(primaryColor).scalePreservingAspectRatio(targetSize: CGSize(width: 22, height: 22))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleAddQuote), for: .touchUpInside)
        return button
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(disciplines: [Discipline]) {
        self.disciplines = disciplines
        super.init(frame: .zero)
        configure()
    }
    
    func set(disciplines: [Discipline]) {
        self.disciplines = disciplines
        collectionView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(FilterCasesCell.self, forCellWithReuseIdentifier: postDisciplinesCellReuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.bounces = true
        collectionView.alwaysBounceHorizontal = true
        collectionView.alwaysBounceVertical = false
        collectionView.allowsSelection = true
        addSubviews(collectionView, addMediaButton, addReferenceButton, separatorView)
        NSLayoutConstraint.activate([
            addMediaButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            addMediaButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            addMediaButton.heightAnchor.constraint(equalToConstant: 22),
            addMediaButton.widthAnchor.constraint(equalToConstant: 22),
            
            addReferenceButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            addReferenceButton.trailingAnchor.constraint(equalTo: addMediaButton.leadingAnchor, constant: -10),
            addReferenceButton.heightAnchor.constraint(equalToConstant: 22),
            addReferenceButton.widthAnchor.constraint(equalToConstant: 22),
            
            separatorView.trailingAnchor.constraint(equalTo: addReferenceButton.leadingAnchor, constant: -10),
            separatorView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            separatorView.widthAnchor.constraint(equalToConstant: 0.4),
            
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: separatorView.leadingAnchor)
        ])

        backgroundColor = .systemBackground
        barTintColor = UIColor.systemBackground
        setBackgroundImage(UIImage(), forToolbarPosition: .bottom, barMetrics: .default)
        separatorView.backgroundColor = separatorColor
       
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(300), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(300), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func handleUpdateMediaButtonInteraction(forNumberOfImages number: Int) {
        addMediaButton.isEnabled = number < 4
    }
    
    @objc func handleAddMediaButton() {
        toolbarDelegate?.didTapAddMediaButton()
    }
    
    @objc func handleAddQuote() {
        toolbarDelegate?.didTapQuoteButton()
    }
}

extension PostToolbar: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return disciplines.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postDisciplinesCellReuseIdentifier, for: indexPath) as! FilterCasesCell
        cell.set(discipline: disciplines[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        toolbarDelegate?.didTapConfigureDisciplines()
        return false
    }
}


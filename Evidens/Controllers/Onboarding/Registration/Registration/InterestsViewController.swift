//
//  TopicsInterestViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/3/23.
//

import UIKit

private let interestsRegistrationHeaderReuseIdentifier = "InterestsHeaderReuseIdentifier"
private let filterCellReuseIdentifier = "filterCellReuseIdentifier"

class InterestsViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var interests = Speciality.odontologySpecialities()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureCollectionView()
    }
    
    private func configureNavigationBar() {
        title = "Your Interests"
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.register(InterestsRegistrationHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: interestsRegistrationHeaderReuseIdentifier)
        collectionView.register(FilterCasesCell.self, forCellWithReuseIdentifier: filterCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
            
            /*
             /*
              let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .estimated(200), heightDimension: .fractionalHeight(1)))
              let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .estimated(200), heightDimension: .absolute(30)), subitems: [item])
              */
             */
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(300), heightDimension: .absolute(30))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(300), heightDimension: .absolute(30))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            //let outterGroupSize = NSCollectionLayoutSize(widthDimension: .estimated(300), heightDimension: .absolute(90))
            //let outterGroup = NSCollectionLayoutGroup.vertical(layoutSize: outterGroupSize, subitem: group, count: 3)
            
            let outterGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(3), heightDimension: .absolute(30))
            let outterGroup = NSCollectionLayoutGroup.horizontal(layoutSize: outterGroupSize, subitems: [group])
            
            let finalOutterGroupSize = NSCollectionLayoutSize(widthDimension: .estimated(300), heightDimension: .absolute(90))
            let finalOutterGroup = NSCollectionLayoutGroup.vertical(layoutSize: finalOutterGroupSize, subitems: [outterGroup])
            
            //group.interItemSpacing = NSCollectionLayoutSpacing.fixed(10)
            
            let section = NSCollectionLayoutSection(group: finalOutterGroup)
            
            section.boundarySupplementaryItems = [header]
            section.orthogonalScrollingBehavior = .continuous

            return section
        }
        
        return layout
    }
}

extension InterestsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return interests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: filterCellReuseIdentifier, for: indexPath) as! FilterCasesCell
        //cell.tagsLabel.text = displayDataSource[indexPath.row]
        cell.setText(text: interests[indexPath.row].name)
        //if isInSearchMode { collectionView.selectItem(at: IndexPath(item: 1, section: 0), animated: false, scrollPosition: .left) }
        return cell
    }
 
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: interestsRegistrationHeaderReuseIdentifier, for: indexPath) as! InterestsRegistrationHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            print(interests[indexPath.row].name)
    }
}


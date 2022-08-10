//
//  PatentSectionViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/8/22.
//

import UIKit

private let patentCellReuseIdentifier = "PatentCellReuseIdentifier"

class PatentSectionViewController: UICollectionViewController {
    
    private var patents = [[String: String]]()
    private var isCurrentUser: Bool
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
    }
    
    init(patents: [[String: String]], isCurrentUser: Bool) {
        self.patents = patents
        self.isCurrentUser = isCurrentUser
        
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
            
            
            let section = NSCollectionLayoutSection(group: group)
            
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 0
        layout.configuration = config
        
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCollectionView() {
        collectionView.register(UserProfilePatentCell.self, forCellWithReuseIdentifier: patentCellReuseIdentifier)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: patentCellReuseIdentifier, for: indexPath) as! UserProfilePatentCell
        cell.set(patentInfo: patents[indexPath.row])
        cell.delegate = self
        cell.separatorView.isHidden = indexPath.row == 0 ? true : false
        
        cell.buttonImage.isHidden = isCurrentUser ? false : true
        cell.buttonImage.isUserInteractionEnabled = isCurrentUser ? true : false
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return patents.count
    }
}

extension PatentSectionViewController: UserProfilePatentCellDelegate {
    func didTapEditPatent(_ cell: UICollectionViewCell, patentTitle: String, patentNumber: String, patentDescription: String) {

        let controller = AddPatentViewController()
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .black
        navigationItem.backBarButtonItem = backItem
        
        controller.configureWithPublication(patentTitle: patentTitle, patentNumber: patentNumber, patentDescription: patentDescription)
        navigationController?.pushViewController(controller, animated: true)
        
    }
}


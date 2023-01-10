//
//  ExperienceSectionViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/8/22.
//

import UIKit

private let experienceCellReuseIdentifier = "ExperienceCellReuseIdentifier"


class ExperienceSectionViewController: UICollectionViewController {
    
    private var experience = [[String: String]]()
    private var isCurrentUser: Bool
    
    weak var delegate: EditProfileViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        title = "Experiences"
    }
    
    init(experience: [[String: String]], isCurrentUser: Bool) {
        self.experience = experience
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
        collectionView.register(UserProfileExperienceCell.self, forCellWithReuseIdentifier: experienceCellReuseIdentifier)
        collectionView.backgroundColor = .systemBackground
        view.backgroundColor = .systemBackground
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: experienceCellReuseIdentifier, for: indexPath) as! UserProfileExperienceCell
        cell.set(experienceInfo: experience[indexPath.row])
        cell.delegate = self
        cell.separatorView.isHidden = indexPath.row == 0 ? true : false
        
        cell.buttonImage.isHidden = isCurrentUser ? false : true
        cell.buttonImage.isUserInteractionEnabled = isCurrentUser ? true : false
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return experience.count
    }
}

extension ExperienceSectionViewController: UserProfileExperienceCellDelegate {
    func didTapEditExperience(_ cell: UICollectionViewCell, company: String, role: String, startDate: String, endDate: String) {
        let controller = AddExperienceViewController()
        controller.delegate = self
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
        controller.configureWithProfession(company: company, role: role, startDate: startDate, endDate: endDate)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension ExperienceSectionViewController: AddExperienceViewControllerDelegate {
    func handleUpdateExperience() {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        delegate?.fetchNewExperienceValues(withUid: uid)
    }
}



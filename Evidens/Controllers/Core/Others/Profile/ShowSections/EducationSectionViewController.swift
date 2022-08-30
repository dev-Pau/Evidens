//
//  EducationSectionViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/8/22.
//

import UIKit

private let educationCellReuseIdentifier = "EducationCellReuseIdentifier"

class EducationSectionViewController: UICollectionViewController {
    
    weak var delegate: EditProfileViewControllerDelegate?
    
    private var education = [[String: String]]()
    private var isCurrentUser: Bool
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        title = "Education"
    }
    
    init(education: [[String: String]], isCurrentUser: Bool) {
        self.education = education
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
        collectionView.register(UserProfileEducationCell.self, forCellWithReuseIdentifier: educationCellReuseIdentifier)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: educationCellReuseIdentifier, for: indexPath) as! UserProfileEducationCell
        cell.set(educationInfo: education[indexPath.row])
        cell.delegate = self
        cell.separatorView.isHidden = indexPath.row == 0 ? true : false
        
        cell.buttonImage.isHidden = isCurrentUser ? false : true
        cell.buttonImage.isUserInteractionEnabled = isCurrentUser ? true : false
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return education.count
    }
}

extension EducationSectionViewController: UserProfileEducationCellDelegate {
    func didTapEditEducation(_ cell: UICollectionViewCell, educationSchool: String, educationDegree: String, educationField: String, educationStartDate: String, educationEndDate: String) {
        let controller = AddEducationViewController()
        controller.delegate = self
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .black
        navigationItem.backBarButtonItem = backItem
        
        controller.configureWithPublication(school: educationSchool, degree: educationDegree, field: educationField, startDate: educationStartDate, endDate: educationEndDate)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension EducationSectionViewController: AddEducationViewControllerDelegate {
    func handleUpdateEducation() {
        delegate?.fetchNewEducationValues()
    }
    
    
}


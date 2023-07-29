//
//  ConfigureSectionViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 31/7/22.
//

import UIKit

private let configureSectionTitleCellReuseIdentifier = "ConfigureSectionTitleCellReuseIdentifier"

protocol ConfigureSectionViewControllerDelegate: AnyObject {
    func aboutSectionDidChange()
    func experienceSectionDidChange()
    func educationSectionDidChange()
    func patentSectionDidChange()
    func publicationSectionDidChange()
    func languageSectionDidChange()
}

class ConfigureSectionViewController: UIViewController {
    
    private let user: User

    weak var delegate: ConfigureSectionViewControllerDelegate?
    
    private let dataSource: [String] = ["About", "Experience", "Education", "Patent", "Publication", "Language"]
    private let dataImages: [String] = ["person", "cross.case", "books.vertical", "book", "heart.text.square", "character.bubble"]
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 50)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
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
        navigationItem.title = "Add Sections"
    }
    
    private func configureCollectionView() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ConfigureSectionCell.self, forCellWithReuseIdentifier: configureSectionTitleCellReuseIdentifier)
    }
}


extension ConfigureSectionViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: configureSectionTitleCellReuseIdentifier, for: indexPath) as! ConfigureSectionCell
        cell.set(title: dataSource[indexPath.row], image: dataImages[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        backItem.tintColor = .label
        
        if indexPath.row == 0 {
            let controller = AddAboutViewController()
            controller.delegate = self
            controller.title = "About"
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.row == 1 {
            let controller = AddExperienceViewController()
            controller.hidesBottomBarWhenPushed = true
            controller.delegate = self
            controller.title = "Experience"
            navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.row == 2 {
            let controller = AddEducationViewController()
            controller.hidesBottomBarWhenPushed = true
            controller.delegate = self
            controller.title = "Education"
            navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.row == 3 {
            let controller = AddPatentViewController(user: user)
            controller.hidesBottomBarWhenPushed = true
            controller.delegate = self
            controller.title = "Patent"
            navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.row == 4 {
            let controller = AddPublicationViewController(user: user)
            controller.hidesBottomBarWhenPushed = true
            controller.delegate = self
            controller.title = "Publication"
            navigationController?.pushViewController(controller, animated: true)
        } else {
            let controller = AddLanguageViewController()
            controller.hidesBottomBarWhenPushed = true
            controller.delegate = self
            controller.title = "Language"
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension ConfigureSectionViewController: AddAboutViewControllerDelegate, AddExperienceViewControllerDelegate, AddEducationViewControllerDelegate, AddPatentViewControllerDelegate, AddPublicationViewControllerDelegate, AddLanguageViewControllerDelegate {
    func handleUpdateExperience(experience: Experience) {
        handleUpdateExperience()
    }
    
    func handleDeleteExperience(experience: Experience) {
        handleUpdateExperience(experience: experience)
    }
    

    func handleDeleteEducation(education: Education) {
        handleUpdateEducation(education: education)
    }
    

    func handleDeletePublication(publication: Publication) {
        handleUpdatePublication(publication: publication)
    }
    
    func handleLanguageUpdate(language: Language) {
        delegate?.languageSectionDidChange()
    }
    
    func deleteLanguage(language: Language) {
        handleLanguageUpdate(language: language)
    }
    
    func handleUpdatePublication(publication: Publication) {
        delegate?.publicationSectionDidChange()
    }
    
    func handleDeletePatent(patent: Patent) {
        handleUpdatePatent(patent: patent)
    }
    
    func handleUpdatePatent(patent: Patent) {
        delegate?.patentSectionDidChange()
    }
    
    func handleUpdateEducation(education: Education) {
        delegate?.educationSectionDidChange()
    }
    
    func handleUpdateExperience() {
        delegate?.experienceSectionDidChange()
    }
    
    func handleUpdateAbout() {
        delegate?.aboutSectionDidChange()
    }
}

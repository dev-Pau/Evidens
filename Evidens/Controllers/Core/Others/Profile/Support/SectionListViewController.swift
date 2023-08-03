//
//  SectionListViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 31/7/22.
//

import UIKit

private let configureSectionTitleCellReuseIdentifier = "ConfigureSectionTitleCellReuseIdentifier"

protocol SectionListViewControllerDelegate: AnyObject {
    func aboutSectionDidChange()
    func experienceSectionDidChange()
    func educationSectionDidChange()
    func patentSectionDidChange()
    func publicationSectionDidChange()
    func languageSectionDidChange()
}

class SectionListViewController: UIViewController {
    
    private let user: User

    weak var delegate: SectionListViewControllerDelegate?
    
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
        navigationItem.title = AppStrings.Title.section
    }
    
    private func configureCollectionView() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SectionCell.self, forCellWithReuseIdentifier: configureSectionTitleCellReuseIdentifier)
    }
}

extension SectionListViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Sections.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: configureSectionTitleCellReuseIdentifier, for: indexPath) as! SectionCell
        cell.set(section: Sections.allCases[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            let controller = AddAboutViewController(comesFromOnboarding: false)
            controller.delegate = self
            controller.title = Sections.allCases[indexPath.row].title
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.row == 1 {
            let controller = AddExperienceViewController()
            controller.hidesBottomBarWhenPushed = true
            controller.delegate = self
            controller.title = Sections.allCases[indexPath.row].title
            navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.row == 2 {
            let controller = AddEducationViewController()
            controller.hidesBottomBarWhenPushed = true
            controller.delegate = self
            controller.title = Sections.allCases[indexPath.row].title
            navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.row == 3 {
            let controller = AddPatentViewController(user: user)
            controller.hidesBottomBarWhenPushed = true
            controller.delegate = self
            controller.title = Sections.allCases[indexPath.row].title
            navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.row == 4 {
            let controller = AddPublicationViewController(user: user)
            controller.hidesBottomBarWhenPushed = true
            controller.delegate = self
            controller.title = Sections.allCases[indexPath.row].title
            navigationController?.pushViewController(controller, animated: true)
        } else {
            let controller = AddLanguageViewController()
            controller.hidesBottomBarWhenPushed = true
            controller.delegate = self
            controller.title = Sections.allCases[indexPath.row].title
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension SectionListViewController: AddAboutViewControllerDelegate, AddExperienceViewControllerDelegate, AddEducationViewControllerDelegate, AddPatentViewControllerDelegate, AddPublicationViewControllerDelegate, AddLanguageViewControllerDelegate {
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

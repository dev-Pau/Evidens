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
        return Section.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: configureSectionTitleCellReuseIdentifier, for: indexPath) as! SectionCell
        cell.set(section: Section.allCases[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard user.isCurrentUser else { return }
        let section = Section.allCases[indexPath.row]
        switch section {
        case .about:
            let controller = AddAboutViewController(comesFromOnboarding: false)
            controller.delegate = self
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true)
        case .experience:
            let controller = AddExperienceViewController()
            controller.hidesBottomBarWhenPushed = true
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        case .education:
            let controller = AddEducationViewController()
            controller.hidesBottomBarWhenPushed = true
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        case .patent:
            let controller = AddPatentViewController(user: user)
            controller.hidesBottomBarWhenPushed = true
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        case .publication:
            let controller = AddPublicationViewController(user: user)
            controller.hidesBottomBarWhenPushed = true
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        case .language:
            let controller = AddLanguageViewController()
            controller.hidesBottomBarWhenPushed = true
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension SectionListViewController: AddAboutViewControllerDelegate, AddExperienceViewControllerDelegate, AddEducationViewControllerDelegate, AddPatentViewControllerDelegate, AddPublicationViewControllerDelegate, AddLanguageViewControllerDelegate {
    
    func didDeletePatent(_ patent: Patent) {
        didAddPatent(patent)
    }
    
    func didDeletePublication(_ publication: Publication) {
        didAddPublication(publication)
    }
    
    func didDeleteLanguage(_ language: Language) {
        didAddLanguage(language)
    }
    
    func didAddExperience(_ experience: Experience) {
        handleUpdateExperience()
    }
    
    func didDeleteExperience(_ experience: Experience) {
        didAddExperience(experience)
    }
    

    func didDeleteEducation(_ education: Education) {
        didAddEducation(education)
    }
    

    func handleDeletePublication(publication: Publication) {
        didAddPublication(publication)
    }
    
    func didAddLanguage(_ language: Language) {
        delegate?.languageSectionDidChange()
    }
    
    func didAddPublication(_ publication: Publication) {
        delegate?.publicationSectionDidChange()
    }
    
    func handleDeletePatent(patent: Patent) {
        didAddPatent(patent)
    }
    
    func didAddPatent(_ patent: Patent) {
        delegate?.patentSectionDidChange()
    }
    
    func didAddEducation(_ education: Education) {
        delegate?.educationSectionDidChange()
    }
    
    func handleUpdateExperience() {
        delegate?.experienceSectionDidChange()
    }
    
    func handleUpdateAbout() {
        delegate?.aboutSectionDidChange()
    }
}

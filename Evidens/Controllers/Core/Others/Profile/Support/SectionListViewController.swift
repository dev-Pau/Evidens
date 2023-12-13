//
//  SectionListViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 31/7/22.
//

import UIKit

private let sectionCellReuseIdentifier = "SectionCellReuseIdentifier"

protocol SectionListViewControllerDelegate: AnyObject {
    func aboutSectionDidChange()
    func websiteSectionDidChange()
    func publicationSectionDidChange()
    func languageSectionDidChange()
}

class SectionListViewController: UIViewController {
    
    private let user: User

    weak var delegate: SectionListViewControllerDelegate?
    
    private var collectionView: UICollectionView!
  
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
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        
        let item = NSCollectionLayoutItem(layoutSize: size)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func configureCollectionView() {
        view.backgroundColor = .systemBackground
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SectionCell.self, forCellWithReuseIdentifier: sectionCellReuseIdentifier)
    }
}

extension SectionListViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Section.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: sectionCellReuseIdentifier, for: indexPath) as! SectionCell
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
        case .website:
            let controller = AddWebsiteViewController()
            controller.delegate = self
            controller.hidesBottomBarWhenPushed = true
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

extension SectionListViewController: AddAboutViewControllerDelegate, AddPublicationViewControllerDelegate, AddLanguageViewControllerDelegate, AddWebsiteViewControllerDelegate {
    
    func handleUpdateWebsite() {
        delegate?.websiteSectionDidChange()
    }
    
    func didDeletePublication(_ publication: Publication) {
        didAddPublication(publication)
    }
    
    func didDeleteLanguage(_ language: Language) {
        didAddLanguage(language)
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

    func handleUpdateAbout() {
        delegate?.aboutSectionDidChange()
    }
}

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
    
    weak var delegate: ConfigureSectionViewControllerDelegate?
    
    private let dataSource: [String] = ["Add about", "Add experience", "Add education", "Add patent", "Add publication", "Add language"]
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 100)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Sections"
    }
    
    private func configureCollectionView() {
        view.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ConfigureSectionTitleCell.self, forCellWithReuseIdentifier: configureSectionTitleCellReuseIdentifier)
    }
}


extension ConfigureSectionViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: configureSectionTitleCellReuseIdentifier, for: indexPath) as! ConfigureSectionTitleCell
        cell.set(title: dataSource[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        backItem.tintColor = .black
        
        if indexPath.row == 0 {
            let controller = AddAboutViewController()
            controller.delegate = self
            controller.title = "About"
            navigationController?.pushViewController(controller, animated: true)
            
        } else if indexPath.row == 1 {
            let controller = AddExperienceViewController()
            controller.delegate = self
            controller.title = "Experience"
            navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.row == 2 {
            let controller = AddEducationViewController()
            controller.delegate = self
            controller.title = "Education"
            navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.row == 3 {
            let controller = AddPatentViewController()
            controller.delegate = self
            controller.title = "Patent"
            navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.row == 4 {
            let controller = AddPublicationViewController()
            controller.delegate = self
            controller.title = "Publication"
            navigationController?.pushViewController(controller, animated: true)
        } else {
            let controller = AddLanguageViewController()
            controller.delegate = self
            controller.title = "Language"
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension ConfigureSectionViewController: AddAboutViewControllerDelegate, AddExperienceViewControllerDelegate, AddEducationViewControllerDelegate, AddPatentViewControllerDelegate, AddPublicationViewControllerDelegate, AddLanguageViewControllerDelegate {
    
    func handleLanguageUpdate() {
        delegate?.languageSectionDidChange()
    }
    
    func handleUpdatePublication() {
        delegate?.publicationSectionDidChange()
    }
    
    func handleUpdatePatent() {
        delegate?.patentSectionDidChange()
    }
    
    func handleUpdateEducation() {
        delegate?.educationSectionDidChange()
    }
    
    func handleUpdateExperience() {
        delegate?.experienceSectionDidChange()
    }
    
    func handleUpdateAbout() {
        delegate?.aboutSectionDidChange()
    }
}


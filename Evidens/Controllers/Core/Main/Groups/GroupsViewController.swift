//
//  GroupsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/11/22.
//

import UIKit

private let exploreHeaderCellReuseIdentifier = "ExploreHeaderReuseIdentifier"
private let groupManagerCellReuseIdentifier = "GroupManagerCellReuseIdentifier"
private let groupContentCellReuseIdentifier = "ExploreCellReuseIdentifier"


class GroupsViewController: NavigationBarViewController {
    
    private var user: User
    
    private let groupsListCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 120)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Groups"
        view.backgroundColor = .white
        configureCollectionView()
        configureUI()
    }
    
    private func configureCollectionView() {
        groupsListCollectionView.backgroundColor = lightColor
        groupsListCollectionView.delegate = self
        groupsListCollectionView.dataSource = self
        groupsListCollectionView.register(DiscoverGroupCell.self, forCellWithReuseIdentifier: exploreHeaderCellReuseIdentifier)
        groupsListCollectionView.register(GroupManagerCell.self, forCellWithReuseIdentifier: groupManagerCellReuseIdentifier)
        groupsListCollectionView.register(ExploreGroupsCell.self, forCellWithReuseIdentifier: groupContentCellReuseIdentifier)
        
        // el group manager header té tots els grups que forma part l'usuari i els pot seleccionar com linsta, que apretes i et surt un menú a baix dels grups que forma part.
        // primer surtin els grups que
        // la part de explorar grups, que surti el nom
        // llavors es van afegint la resta, de posts publicacions o opinions
    }
    
    private func configureUI() {
        view.addSubview(groupsListCollectionView)
        groupsListCollectionView.frame = view.bounds
    }
}

extension GroupsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // posar-ho en funció de la secció
        if section == 0 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        if section == 1 { return 1 }
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: exploreHeaderCellReuseIdentifier, for: indexPath) as! DiscoverGroupCell
            cell.delegate = self
            return cell
        } else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupManagerCellReuseIdentifier, for: indexPath) as! GroupManagerCell
            cell.set(user: user)
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupContentCellReuseIdentifier, for: indexPath) as! ExploreGroupsCell
        return cell
    }
}

extension GroupsViewController: DiscoverGroupCellDelegate {
    
    func didTapDiscover() {
        let controller = DiscoverGroupsViewController()
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .black
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

//
//  SideMenuViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/9/22.
//

import UIKit

private let sideMenuCellReuseIdentifier = "SideMenuCellReuseIdentifier"
private let sideMenuHeaderReuseIdentifier = "SideMenuHeaderReuseIdentifier"

protocol SideMenuViewControllerDelegate: AnyObject {
    func didTapMenuHeader()
}

class SideMenuViewController: UIViewController {
    
    weak var delegate: SideMenuViewControllerDelegate?
    
    enum MenuOptions: String, CaseIterable {
        case bookmarks = "Bookmarks"
        case posts = "Posts"
    }
    
    private var menuWidth: CGFloat = UIScreen.main.bounds.width - 50
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SideMenuCell.self, forCellWithReuseIdentifier: sideMenuCellReuseIdentifier)
        collectionView.register(SideMenuHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: sideMenuHeaderReuseIdentifier)
    }
}

extension SideMenuViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: sideMenuHeaderReuseIdentifier, for: indexPath) as! SideMenuHeader
        header.delegate = self
        return header
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MenuOptions.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: sideMenuCellReuseIdentifier, for: indexPath) as! SideMenuCell
        cell.set(title: MenuOptions.allCases[indexPath.row].rawValue)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Did select")
    }
}

extension SideMenuViewController: SideMenuHeaderDelegate {
    func didTapHeader() {
        delegate?.didTapMenuHeader()
    }
}

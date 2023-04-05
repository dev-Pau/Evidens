//
//  SearchAssisstantMenuLauncher.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 5/4/23.
//

import UIKit

private let cellReuseIdentifier = "PostMenuCellReuseIdentifier"
private let footerSearchMenuLauncherReuseIdentifier = "FooterSearchMenuLauncherReuseIdentifier"
private let headerReuseIdentifier = "PostMenuHeaderReuseIdentifier"

class SearchAssistantMenuLauncher: NSObject {
    
    private let blackBackgroundView: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        return view
    }()
    
    
    weak var delegate: PostBottomMenuLauncherDelegate?
    private let searchOptions: [String]
    private var menuHeight: CGFloat = 210 //110 + 60 + 60 + 30 - 260
    private let menuYOffset: CGFloat = UIScreen.main.bounds.height
    
    private var screenWidth: CGFloat = UIScreen.main.bounds.width
    
    private var collectionView: UICollectionView!

    func showPostSettings(in view: UIView) {
        screenWidth = view.frame.width
        
        configurePostSettings(in: view)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blackBackgroundView.alpha = 1
            self.collectionView.frame = CGRect(x: 0, y: self.menuYOffset - self.menuHeight, width: self.screenWidth, height: self.menuHeight)
        }, completion: nil)
    }
    
    @objc func handleDismiss() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.blackBackgroundView.alpha = 0
            self.collectionView.frame = CGRect(x: 0, y: self.menuYOffset, width: self.screenWidth, height: self.menuHeight)
        } completion: { completed in
        }
    }
    
    @objc func handleDismissMenu() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.blackBackgroundView.alpha = 0
            self.collectionView.frame = CGRect(x: 0, y: self.menuYOffset, width: self.screenWidth, height: self.menuHeight)
        }
    }

    func configurePostSettings(in view: UIView) {
        view.addSubview(blackBackgroundView)
        view.addSubview(collectionView)
        
        blackBackgroundView.frame = view.frame
        blackBackgroundView.backgroundColor = .label.withAlphaComponent(0.3)
        blackBackgroundView.alpha = 0
        
        blackBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismissMenu)))
        
        collectionView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: screenWidth, height: menuHeight)

    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.layer.cornerRadius = 20
        collectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MESearchMenuHeder.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: headerReuseIdentifier)
        collectionView.register(MESearchMenuFooter.self, forSupplementaryViewOfKind: ElementKind.sectionFooter, withReuseIdentifier: footerSearchMenuLauncherReuseIdentifier)
        collectionView.register(RegistrationInterestsCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView.isScrollEnabled = false
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        collectionView.addGestureRecognizer(pan)
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(65))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(320), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .estimated(320), heightDimension: .absolute(40)), subitems: [item])
        
        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(45))
        let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: ElementKind.sectionFooter, alignment: .bottom)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 10
        section.boundarySupplementaryItems = [header, footer]
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    @objc func handlePan(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: collectionView)
        
        collectionView.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.height - menuHeight + translation.y * 0.3)
        
        if sender.state == .ended {
            if translation.y > 0 && translation.y > menuHeight * 0.3 {
                UIView.animate(withDuration: 0.3) {
                    //self.handleDismiss(selectedOption: "")
                    self.handleDismiss()
                }
            } else {
                UIView.animate(withDuration: 0.5) {
                    self.collectionView.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.height - self.menuHeight)
                    self.collectionView.frame.size.height = self.menuHeight
                }
            }
        } else {
            collectionView.frame.size.height = menuHeight - translation.y * 0.3
        }
    }
    
    init(searchOptions: [String]) {
        self.searchOptions = searchOptions
        super.init()
        configureCollectionView()
    }
}

extension SearchAssistantMenuLauncher: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == ElementKind.sectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! MESearchMenuHeder
            header.menuTitle.text = "Filter"
            return header
        } else {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerSearchMenuLauncherReuseIdentifier, for: indexPath) as! MESearchMenuFooter
            return footer
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! RegistrationInterestsCell
        cell.setText(text: searchOptions[indexPath.row])
        //cell.set(withText: searchOptions[indexPath.row], withImage: ShareableContent.clinicalCase.contentImage)
        //cell.backgroundColor = UIColor.init(named: "bottomMenuCellColor")
        //cell.backgroundColor = .tertiarySystemFill

        /*
        if indexPath.row == 0 {
            cell.layer.cornerRadius = 10
            cell.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
        
        if indexPath.row == ShareableContent.allCases.count - 1 {
            cell.layer.cornerRadius = 10
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
         */
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedOption = ShareableContent.allCases[indexPath.row]
        delegate?.didTapUpload(content: selectedOption)
        handleDismissMenu()
    }
}


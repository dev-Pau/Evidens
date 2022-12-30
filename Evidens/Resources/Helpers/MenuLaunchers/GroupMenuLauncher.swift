//
//  GroupMenuLauncher.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 9/12/22.
//

import UIKit

private let cellReuseIdentifier = "GroupMenuCellReuseIdentifier"
private let headerReuseIdentifier = "GroupMenuHeaderReuseIdentifier"

protocol GroupMenuLauncherDelegate: AnyObject {
    func didTapVisitGroup()
    func didTapBrowseGroups()
    func didTapDiscoverGroups()
}

class GroupMenuLauncher: NSObject {
    
    weak var delegate: GroupMenuLauncherDelegate?
    
    private let blackBackgroundView: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        return view
    }()

    private let menuHeight: CGFloat = 55 + CGFloat(GroupMenuOptions.allCases.count * 55)
    private let menuYOffset: CGFloat = UIScreen.main.bounds.height
    
    private var screenWidth: CGFloat = 0
    
    enum GroupMenuOptions: CaseIterable {
        case page
        case browse
        case discover
        
        var groupMenuString: String {
            switch self {
            case .page:
                return "Visit group page"
            case .browse:
                return "Browse groups"
            case .discover:
                return "Discover new groups"
            }
        }
        
        var groupMenuImage: UIImage {
            switch self {
            case .page:
                return UIImage(systemName: "arrow.right", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
            case .browse:
                return UIImage(systemName: "list.bullet", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
            case .discover:
                return UIImage(systemName: "safari", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
            }
        }
    }
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = lightColor
        collectionView.layer.cornerRadius = 20
        collectionView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        return collectionView
    }()
    
    
    func showGroupSettings(in view: UIView) {
        screenWidth = view.frame.width
        
        configurePostSettings(in: view)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.blackBackgroundView.alpha = 1
            self.collectionView.frame = CGRect(x: 0, y: self.menuYOffset - self.menuHeight, width: self.screenWidth, height: self.menuHeight)
        }
    }
    
    
    @objc func handleDismiss(selectedOption: String?) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.blackBackgroundView.alpha = 0
            self.collectionView.frame = CGRect(x: 0, y: self.menuYOffset, width: self.screenWidth, height: self.menuHeight)
        } completion: { _ in
            switch selectedOption {
            case GroupMenuOptions.page.groupMenuString:
                self.delegate?.didTapVisitGroup()
            case GroupMenuOptions.discover.groupMenuString:
                self.delegate?.didTapDiscoverGroups()
            case GroupMenuOptions.browse.groupMenuString:
                self.delegate?.didTapBrowseGroups()
            default:
                break
            }
        }
    }
    
    @objc func handleDismissMenu() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.blackBackgroundView.alpha = 0
            self.collectionView.frame = CGRect(x: 0, y: self.menuYOffset, width: self.screenWidth, height: self.menuHeight)
        }
    }

    
    
    func configurePostSettings(in view: UIView) {
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(blackBackgroundView)
            window.addSubview(collectionView)
        }
        
        blackBackgroundView.frame = view.frame
        blackBackgroundView.backgroundColor = .black.withAlphaComponent(0.5)
        blackBackgroundView.alpha = 0
        
        blackBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismissMenu)))
        
        collectionView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: screenWidth, height: menuHeight)
    }
    
    private func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PostMenuHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)
        collectionView.register(PostMenuCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView.isScrollEnabled = false
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        collectionView.addGestureRecognizer(pan)
    }
    
    @objc func handlePan(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: collectionView)
        
        collectionView.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.height - menuHeight + translation.y * 0.3)
        
        if sender.state == .ended {
            if translation.y > 0 && translation.y > menuHeight * 0.3 {
                UIView.animate(withDuration: 0.3) {
                    self.handleDismiss(selectedOption: "")
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
    
    
    override init() {
        super.init()
        configureCollectionView()
    }
}

extension GroupMenuLauncher: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! PostMenuHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: screenWidth, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return GroupMenuOptions.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! PostMenuCell
        cell.set(withText: GroupMenuOptions.allCases[indexPath.row].groupMenuString, withImage: GroupMenuOptions.allCases[indexPath.row].groupMenuImage)
        cell.backgroundColor = .white

        if indexPath.row == 0 {
            cell.layer.cornerRadius = 10
            cell.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
        
        else if indexPath.row == GroupMenuOptions.allCases.count - 1 {
            cell.layer.cornerRadius = 10
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
         } else {
             cell.layer.cornerRadius = 0
         }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth - 40, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedOption = GroupMenuOptions.allCases[indexPath.row].groupMenuString
        handleDismiss(selectedOption: selectedOption)

    }
}


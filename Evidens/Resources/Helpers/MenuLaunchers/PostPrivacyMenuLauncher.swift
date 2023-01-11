//
//  PostPrivacyMenuLauncher.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/6/22.
//

import UIKit

private let cellReuseIdentifier = "PostPrivacyCellReuseIdentifier"
private let headerReuseIdentifier = "PostPrivacyHeaderReuseIdentifier"


protocol PostPrivacyMenuLauncherDelegate: AnyObject {
    func didDissmisMenu()
    func didTapPrivacyOption(_ option: Post.PrivacyOptions)
                             //, _ image: UIImage, _ privacyText: String)
}

class PostPrivacyMenuLauncher: NSObject {
    
    private var privacyOption: Post.PrivacyOptions = .all

    private let blackBackgroundView: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        return view
    }()
    
    var selectedOption = 0
    
    private var comesFromGroup: Bool = false
    private var groupIsSelected: Bool = false
    private var group = Group(groupId: "", dictionary: [:])
    
    weak var delegate: PostPrivacyMenuLauncherDelegate?
    
    private var menuHeight: CGFloat = 110 + CGFloat(Post.PrivacyOptions.allCases.count * 55)
    private let menuYOffset: CGFloat = UIScreen.main.bounds.height
    private var userHasGroups: Bool = false
    
    private var screenWidth: CGFloat = 0
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.layer.cornerRadius = 20
        collectionView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        return collectionView
    }()
    
    
    func showPostSettings(in view: UIView) {
        screenWidth = view.frame.width
        
        configurePostSettings(in: view)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blackBackgroundView.alpha = 1
            self.collectionView.frame = CGRect(x: 0, y: self.menuYOffset - self.menuHeight, width: self.screenWidth, height: self.menuHeight)
        }, completion: nil)
    }
    
    func updatePrivacyWithGroupOptions(group: Group) {
        selectedOption = Post.PrivacyOptions.allCases.count - 1
        groupIsSelected = true
        self.group = group
        collectionView.reloadData()
    }
    
    @objc func handleDismiss(selectedOption: String?) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.blackBackgroundView.alpha = 0
            self.collectionView.frame = CGRect(x: 0, y: self.menuYOffset, width: self.screenWidth, height: self.menuHeight)
        } completion: { _ in
            self.delegate?.didDissmisMenu()
        }
    }
    
    @objc func handleDismissMenu() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.blackBackgroundView.alpha = 0
            self.collectionView.frame = CGRect(x: 0, y: self.menuYOffset, width: self.screenWidth, height: self.menuHeight)
        } completion: { _ in
            self.delegate?.didDissmisMenu()
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
        collectionView.register(PostPrivacyHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)
        collectionView.register(PostPrivacyCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
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
    
    private func checkIfUserHasGroups() {
        DatabaseManager.shared.checkIfUserHasGroups { groups in
            self.userHasGroups = groups
            if groups == false { self.menuHeight -= 55 }
            self.collectionView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: self.screenWidth, height: self.menuHeight)
            self.collectionView.reloadData()
        }
    }
    
    func isUploadingPostFromGroup(group: Group) {
        // Upload post directly from groupe
        self.comesFromGroup = true
        self.menuHeight = 110 + 55
        self.collectionView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: self.screenWidth, height: self.menuHeight)
        self.collectionView.reloadData()
    }
    
    
    override init() {
        super.init()
        checkIfUserHasGroups()
        configureCollectionView()
    }
}

extension PostPrivacyMenuLauncher: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! PostPrivacyHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: screenWidth, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if comesFromGroup { return 1 }
        return userHasGroups ? Post.PrivacyOptions.allCases.count : Post.PrivacyOptions.allCases.count - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! PostPrivacyCell
        
        if comesFromGroup {
            cell.configureWithGroupData(group: group)
            cell.selectedOptionButton.configuration?.image = UIImage(systemName: "smallcircle.fill.circle.fill")
            return cell
        }
        
        if indexPath.row == Post.PrivacyOptions.allCases.count - 1 && groupIsSelected {
            cell.configureWithGroupData(group: group)
            
        } else {
            
            cell.set(withText: Post.PrivacyOptions.allCases[indexPath.row].privacyTitle, withSubtitle: Post.PrivacyOptions.allCases[indexPath.row].privacyDescription, withImage: Post.PrivacyOptions.allCases[indexPath.row].privacyImage)
        }
        
        if indexPath.row == selectedOption {
            cell.selectedOptionButton.configuration?.image = UIImage(systemName: "smallcircle.fill.circle.fill")
        } else {
            cell.selectedOptionButton.configuration?.image = UIImage(systemName: "circle")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if comesFromGroup { return }

        let privacyOption = Post.PrivacyOptions.allCases[indexPath.row]
        
        if privacyOption != .group {
            selectedOption = indexPath.row
            groupIsSelected = false
            collectionView.reloadData()
        }
        
        delegate?.didTapPrivacyOption(privacyOption)
        handleDismissMenu()
    }
}



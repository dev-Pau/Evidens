//
//  CasePrivacyMenuLauncher.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/8/22.
//

import UIKit

private let cellReuseIdentifier = "CasePrivacyCellReuseIdentifier"
private let headerReuseIdentifier = "CasePrivacyHeaderReuseIdentifier"


protocol CasePrivacyMenuLauncherDelegate: AnyObject {
    //func didTapPrivacyOption(_ option: Case.Privacy, _ image: UIImage, _ privacyText: String)
    func didTapPrivacyOption(_ option: Case.Privacy)
}

class CasePrivacyMenuLauncher: NSObject {
    
    private var privacyOption: Case.Privacy = .visible
    
    private var groupIsSelected: Bool = false
    private var comesFromGroup: Bool = false
    private var userHasGroups: Bool = false
    private var group = Group(groupId: "", dictionary: [:])
    
    private let blackBackgroundView: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        return view
    }()
    
    var selectedOption = 0
    
    weak var delegate: CasePrivacyMenuLauncherDelegate?
    
    private var menuHeight: CGFloat = 110 + CGFloat(Case.Privacy.allCases.count) * 55 + 20
    private let menuYOffset: CGFloat = UIScreen.main.bounds.height
    
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
        selectedOption = Case.Privacy.allCases.count - 1
        groupIsSelected = true
        self.group = group
        collectionView.reloadData()
    }
    
    
    @objc func handleDismiss(selectedOption: String?) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.blackBackgroundView.alpha = 0
            self.collectionView.frame = CGRect(x: 0, y: self.menuYOffset, width: self.screenWidth, height: self.menuHeight)
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
        blackBackgroundView.backgroundColor = .label.withAlphaComponent(0.3)
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
    
    private func checkIfUserHasGroups() {
        DatabaseManager.shared.checkIfUserHasGroups { groups in
            self.userHasGroups = groups
            if groups == false { self.menuHeight -= 55 }
            self.collectionView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: self.screenWidth, height: self.menuHeight)
            self.collectionView.reloadData()
        }
    }
    
    func isUploadingCaseFromGroup(group: Group) {
        // Upload post directly from groupe
        self.comesFromGroup = true
        self.menuHeight = 110 + 55
        self.collectionView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: self.screenWidth, height: self.menuHeight)
        self.collectionView.reloadData()
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
        checkIfUserHasGroups()
        configureCollectionView()
    }
}

extension CasePrivacyMenuLauncher: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! PostPrivacyHeader
        header.subtitleLabel.text = "Your case will show up on the feed and in search results. Change the privacy mode to unlink the case with your profile"
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: screenWidth, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if comesFromGroup { return 1 }
        return userHasGroups ? Case.Privacy.allCases.count : Case.Privacy.allCases.count - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! PostPrivacyCell
        //cell.backgroundColor = UIColor.init(named: "bottomMenuCellColor")
        if comesFromGroup {
            cell.configureWithGroupData(group: group)
            cell.selectedOptionButton.configuration?.image = UIImage(systemName: "smallcircle.fill.circle.fill")
            return cell
        }
        
        if indexPath.row == Case.Privacy.allCases.count - 1 && groupIsSelected {
            cell.configureWithGroupData(group: group)
            
        } else {
            cell.set(withText: Case.Privacy.allCases[indexPath.row].privacyTypeString, withSubtitle: Case.Privacy.allCases[indexPath.row].privacyTypeSubtitle, withImage: Case.Privacy.allCases[indexPath.row].privacyTypeImage)
        }
       
        if indexPath.row == selectedOption {
            cell.selectedOptionButton.configuration?.image = UIImage(systemName: "smallcircle.fill.circle.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        } else {
            cell.selectedOptionButton.configuration?.image = UIImage(systemName: "circle", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if comesFromGroup { return }
        
        let privacyOption = Case.Privacy.allCases[indexPath.row]
        if privacyOption != .group {
            selectedOption = indexPath.row
            groupIsSelected = false
            collectionView.reloadData()
        }
        
        delegate?.didTapPrivacyOption(privacyOption)
        handleDismissMenu()
    }
}



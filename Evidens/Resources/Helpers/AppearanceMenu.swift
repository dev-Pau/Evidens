//
//  AppearanceMenuLauncher.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/3/23.
//

import UIKit

private let appearanceSettingCellReuseIdentifier = "AppearanceSettingCellReuseIdentifier"
private let headerReuseIdentifier = "PostMenuHeaderReuseIdentifier"
private let footerReuseIdentifier = "FooterReuseIdentifier"


protocol AppearanceMenuDelegate: AnyObject {
    func didTapAppearanceSetting(_ sw: UISwitch, setting: Appearance)
    func didCloseMenu()
}

class AppearanceMenu: NSObject {

    private let blackBackgroundView: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        return view
    }()
    
    weak var delegate: AppearanceMenuDelegate?
    
    private let menuHeight: CGFloat = 260
    private let menuYOffset: CGFloat = UIScreen.main.bounds.height
    
    private var screenWidth: CGFloat = 0
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.layer.cornerRadius = 20
        collectionView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        return collectionView
    }()
    
    func showPostSettings(in view: UIView) {
        screenWidth = view.frame.width
        
        configurePostSettings(in: view)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.blackBackgroundView.alpha = 1
            strongSelf.collectionView.frame = CGRect(x: 0, y: strongSelf.menuYOffset - strongSelf.menuHeight, width: strongSelf.screenWidth, height: strongSelf.menuHeight)
        }, completion: nil)
    }
    
    @objc func handleDismiss() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 1, options: .curveEaseOut) { [weak self] in
            guard let strongSelf = self else { return}
            strongSelf.blackBackgroundView.alpha = 0
            strongSelf.collectionView.frame = CGRect(x: 0, y: strongSelf.menuYOffset, width: strongSelf.screenWidth, height: strongSelf.menuHeight)
        } completion: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.didCloseMenu()

        }
    }
    
    @objc func handleDismissMenu() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 1, options: .curveEaseOut) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.blackBackgroundView.alpha = 0
            strongSelf.collectionView.frame = CGRect(x: 0, y: strongSelf.menuYOffset, width: strongSelf.screenWidth, height: strongSelf.menuHeight)
            strongSelf.delegate?.didCloseMenu()
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
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ContentMenuHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)
        collectionView.register(AppearanceCell.self, forCellWithReuseIdentifier: appearanceSettingCellReuseIdentifier)
        collectionView.register(AppearanceFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerReuseIdentifier)
        collectionView.isScrollEnabled = false
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        collectionView.addGestureRecognizer(pan)
    }
    
    @objc func handlePan(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: collectionView)
        
        collectionView.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.height - menuHeight + translation.y * 0.3)
        
        if sender.state == .ended {
            if translation.y > 0 && translation.y > menuHeight * 0.3 {
                UIView.animate(withDuration: 0.3) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.handleDismiss()
                }
            } else {
                UIView.animate(withDuration: 0.5) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.collectionView.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.height - strongSelf.menuHeight)
                    strongSelf.collectionView.frame.size.height = strongSelf.menuHeight
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

extension AppearanceMenu: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! ContentMenuHeader
            header.setTitle(AppStrings.Appearance.title) 
            return header
        } else {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerReuseIdentifier, for: indexPath) as! AppearanceFooter
            return footer
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: screenWidth, height: 65)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: screenWidth, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Appearance.allCases.count - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: appearanceSettingCellReuseIdentifier, for: indexPath) as! AppearanceCell
        cell.appearance = Appearance.allCases[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth, height: 50)
    }
}

extension AppearanceMenu: AppearanceCellDelegate {
    func didTapSwitch(_ sw: UISwitch, appearance: Appearance) {
        if let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            if let window = windowScene.windows.first {
                
                UIView.transition (with: window, duration: 0.5, options: .transitionCrossDissolve, animations: { [weak self] in
                    guard let _ = self else { return }
                    switch appearance {
                    case .dark:
                        if sw.isOn {
                            UserDefaults.standard.set(appearance.rawValue, forKey: "themeStateEnum")
                            window.overrideUserInterfaceStyle = .dark
                        } else {
                            UserDefaults.standard.set(Appearance.light.rawValue, forKey: "themeStateEnum")
                            window.overrideUserInterfaceStyle = .light
                        }
                        
                    case .system:
                        UserDefaults.standard.set(appearance.rawValue, forKey: "themeStateEnum")
                        if sw.isOn { window.overrideUserInterfaceStyle = .unspecified }
                    case .light: break
                    }
                }) { [weak self] _ in
                    guard let strongSelf = self else { return }
                    // User switched from .dark to .light & .unspecified is on, switch to isOn = false
                    switch appearance {
                    case .dark:
                        if sw.isOn {
                            let cell = strongSelf.collectionView.cellForItem(at: IndexPath(item: 1, section: 0)) as! AppearanceCell
                            cell.closeSwitch()
                        } else {
                            // Change to light content
                            let cell = strongSelf.collectionView.cellForItem(at: IndexPath(item: 1, section: 0)) as! AppearanceCell
                            cell.closeSwitch()
                        }
                    case .system:
                        if window.traitCollection.userInterfaceStyle == .dark {
                            let cell = strongSelf.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as! AppearanceCell
                            cell.openSwitch()
                        } else {
                            let cell = strongSelf.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as! AppearanceCell
                            cell.closeSwitch()
                        }
                    case .light:
                        break
                    }
                    
                    strongSelf.delegate?.didTapAppearanceSetting(sw, setting: appearance)
                }
            }
        }
    }
}

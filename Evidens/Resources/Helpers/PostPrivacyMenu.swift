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
    func didTapPrivacyOption(_ option: PostPrivacy)
}

class PostPrivacyMenu: NSObject {
    
    private var privacy: PostPrivacy

    private let backgroundView: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        return view
    }()
    
    private var selectedIndex = 0
    
    weak var delegate: PostPrivacyMenuLauncherDelegate?
    
    private var menuHeight: CGFloat = 85 + CGFloat(PostPrivacy.allCases.count * 55)
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
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.backgroundView.alpha = 1
            strongSelf.collectionView.frame = CGRect(x: 0, y: strongSelf.menuYOffset - strongSelf.menuHeight, width: strongSelf.screenWidth, height: strongSelf.menuHeight)
        }
    }
    
    @objc func handleDismiss(selectedOption: String?) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 1, options: .curveEaseOut) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.backgroundView.alpha = 0
            strongSelf.collectionView.frame = CGRect(x: 0, y: strongSelf.menuYOffset, width: strongSelf.screenWidth, height: strongSelf.menuHeight)
        } completion: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.didDissmisMenu()
        }
    }
    
    @objc func handleDismissMenu() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 1, options: .curveEaseOut) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.backgroundView.alpha = 0
            strongSelf.collectionView.frame = CGRect(x: 0, y: strongSelf.menuYOffset, width: strongSelf.screenWidth, height: strongSelf.menuHeight)
        } completion: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.didDissmisMenu()
        }
    }

    func configurePostSettings(in view: UIView) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first {
            window.addSubview(backgroundView)
            window.addSubview(collectionView)
        }
        
        backgroundView.frame = view.frame
        backgroundView.backgroundColor = .black.withAlphaComponent(0.5)
        backgroundView.alpha = 0
        
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismissMenu)))
        
        collectionView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: screenWidth, height: menuHeight)
    }
    
    private func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ContentMenuHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)
        collectionView.register(PrivacyContentCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
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
                    strongSelf.handleDismissMenu()
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
        self.privacy = .regular
        super.init()
        configureCollectionView()
    }
}

extension PostPrivacyMenu: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! ContentMenuHeader
        header.setTitle(AppStrings.Content.Headers.privacy)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: screenWidth, height: 65)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        PostPrivacy.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! PrivacyContentCell
        cell.set(postPrivacy: PostPrivacy.allCases[indexPath.row])

        if indexPath.row == selectedIndex {
            cell.selectorButton.configuration?.image = UIImage(systemName: AppStrings.Icons.checkmarkCircleFill)
        } else {
            cell.selectorButton.configuration?.image = UIImage(systemName: AppStrings.Icons.circle)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let privacy = PostPrivacy.allCases[indexPath.row]
        self.privacy = privacy
        delegate?.didTapPrivacyOption(privacy)
        collectionView.reloadData()
        handleDismissMenu()
    }
}


//
//  WhoCanJoinMenuLauncher.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 4/8/22.
//

import UIKit

private let cellReuseIdentifier = "PostMenuCellReuseIdentifier"
private let headerReuseIdentifier = "PostMenuHeaderReuseIdentifier"
private let footerReuseIdentifier = "FooterReuseIdentifier"

class ContextMenu: NSObject {
    private let display: DisplayContent
    
    private let blackBackgroundView: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        return view
    }()
    
    private var menuHeight: CGFloat = 0.0
    
    private let menuYOffset: CGFloat = UIScreen.main.bounds.height
    
    private var screenWidth: CGFloat = 0
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 200)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.layer.cornerRadius = 20
        collectionView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        return collectionView
    }()
    

    func showImageSettings(in view: UIView) {
        screenWidth = view.frame.width
        configureImageSettings(in: view)
        
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        var totalHeight: CGFloat = 0
        
        for index in 0..<numberOfItems {
            let indexPath = IndexPath(item: index, section: 0)
            let cellHeight = calculateCellHeight(at: indexPath)
            totalHeight += cellHeight
        }
        
        menuHeight = totalHeight + 80 + 80

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.blackBackgroundView.alpha = 1
            strongSelf.collectionView.frame = CGRect(x: 0, y: strongSelf.menuYOffset - strongSelf.menuHeight, width: strongSelf.screenWidth, height: strongSelf.menuHeight)
        }, completion: nil)
    }

    func calculateCellHeight(at indexPath: IndexPath) -> CGFloat {
        let dummyCell = ContextMenuCell(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 0))
    
        dummyCell.configure(withDescription: display.description)
        
        dummyCell.translatesAutoresizingMaskIntoConstraints = false
        dummyCell.widthAnchor.constraint(equalToConstant: screenWidth).isActive = true
        let heightConstraint = dummyCell.heightAnchor.constraint(equalToConstant: 1)
        heightConstraint.priority = .defaultLow
        heightConstraint.isActive = true
        
        dummyCell.setNeedsLayout()
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: screenWidth, height: UIView.layoutFittingCompressedSize.height)
        let cellSize = dummyCell.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        
        return cellSize.height
    }

    @objc func handleDismissMenu() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 1, options: .curveEaseOut) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.blackBackgroundView.alpha = 0
            strongSelf.collectionView.frame = CGRect(x: 0, y: strongSelf.menuYOffset, width: strongSelf.screenWidth, height: strongSelf.menuHeight)
        }
    }
    
    func configureImageSettings(in view: UIView) {
        if let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            if let window = windowScene.windows.first {
                window.addSubview(blackBackgroundView)
                window.addSubview(collectionView)
            }
        }

        blackBackgroundView.frame = view.frame
        blackBackgroundView.backgroundColor = .label.withAlphaComponent(0.5)
        blackBackgroundView.alpha = 0
        collectionView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: screenWidth, height: menuHeight)
        blackBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismissMenu)))
    }
    
    private func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ContextMenuHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)
        collectionView.register(ContextMenuFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerReuseIdentifier)
        collectionView.register(ContextMenuCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView.isScrollEnabled = true
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        collectionView.addGestureRecognizer(pan)
        
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.layoutIfNeeded()

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
    
    init(display: DisplayContent) {
        self.display = display
        super.init()
        configureCollectionView()
        collectionView.layoutIfNeeded()
    }
}

extension ContextMenu: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerReuseIdentifier, for: indexPath) as!
            ContextMenuFooter
            footer.delegate = self
            return footer
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! ContextMenuHeader
            header.set(title: display.title)
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: screenWidth, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: screenWidth, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! ContextMenuCell
        cell.configure(withDescription: display.description)
        return cell
    }
}

extension ContextMenu: ContextMenuFooterDelegate {
    func didTapCloseMenu() {
        handleDismissMenu()
    }
}

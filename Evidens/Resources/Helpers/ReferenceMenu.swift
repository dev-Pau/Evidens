//
//  MEReferenceMenuLauncher.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/4/23.
//

import UIKit

private let cellReuseIdentifier = "PostMenuCellReuseIdentifier"
private let headerReuseIdentifier = "PostMenuHeaderReuseIdentifier"
private let referenceCellReuseIdentifier = "ReferenceCellReuseIdentifier"
private let footerReuseIdentifier = "FooterReuseIdentifier"

protocol ReferenceMenuDelegate: AnyObject {
    func didTapReference(reference: Reference)
}

class ReferenceMenu: NSObject {
    weak var delegate: ReferenceMenuDelegate?
    
    private var reference: Reference? {
        didSet {
            activityIndicator.stopAnimating()
            collectionView.reloadData()
        }
    }
    
    private var referenceLoaded = false
    
    private let blackBackgroundView: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        return view
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()

    private var menuHeight: CGFloat = UIScreen.main.bounds.height * 0.5 {
        didSet {
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.blackBackgroundView.alpha = 1
                strongSelf.collectionView.frame = CGRect(x: 0, y: strongSelf.menuYOffset - strongSelf.menuHeight, width: strongSelf.screenWidth, height: strongSelf.menuHeight)
            }, completion: nil)
        }
    }
    private let menuYOffset: CGFloat = UIScreen.main.bounds.height
    
    private var screenWidth: CGFloat = 0
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 100)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.layer.cornerRadius = 20
        collectionView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        return collectionView
    }()
                                                
    func showImageSettings(in view: UIView, forPostId postId: String, forReferenceKind kind: ReferenceKind) {
        screenWidth = view.frame.width
        activityIndicator.startAnimating()
        configureImageSettings(in: view)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [weak self] in
            
            guard let strongSelf = self else { return }
            strongSelf.blackBackgroundView.alpha = 1
            strongSelf.collectionView.frame = CGRect(x: 0, y: strongSelf.menuYOffset - strongSelf.menuHeight, width: strongSelf.screenWidth, height: strongSelf.menuHeight)
            PostService.fetchReference(forPostId: postId, forReferenceKind: kind) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                    
                case .success(let reference):
                    strongSelf.referenceLoaded = true
                    strongSelf.reference = reference

                case .failure(_):
                    break
                }
            }
        }, completion: nil)
    }
    
    @objc func handleDismissMenu() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 1, options: .curveEaseOut) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.blackBackgroundView.alpha = 0
            strongSelf.collectionView.frame = CGRect(x: 0, y: strongSelf.menuYOffset, width: strongSelf.screenWidth, height: strongSelf.menuHeight)
            strongSelf.activityIndicator.stopAnimating()
            strongSelf.referenceLoaded = false
        }
    }
    
    func configureImageSettings(in view: UIView) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.addSubview(blackBackgroundView)
            window.addSubview(collectionView)
            window.addSubview(activityIndicator)
        }

        blackBackgroundView.frame = view.frame
        blackBackgroundView.backgroundColor = .label.withAlphaComponent(0.5)
        blackBackgroundView.alpha = 0
        collectionView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: screenWidth, height: menuHeight)
        blackBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismissMenu)))
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor)
        ])
    }
    
    private func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ContextMenuHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)
        collectionView.register(ContextMenuFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerReuseIdentifier)
        collectionView.register(ReferenceCell.self, forCellWithReuseIdentifier: referenceCellReuseIdentifier)
        collectionView.register(ContextMenuCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView.isScrollEnabled = true
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
        super.init()
        configureCollectionView()
    }
}

extension ReferenceMenu: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerReuseIdentifier, for: indexPath) as!
            ContextMenuFooter
            footer.delegate = self
            if let reference = reference { footer.configureWithReference(reference: reference) }

            let contentSize = collectionView.collectionViewLayout.collectionViewContentSize
            menuHeight = contentSize.height
            return footer
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! ContextMenuHeader
            if let reference = reference { header.set(title: reference.option.message) }
            let contentSize = collectionView.collectionViewLayout.collectionViewContentSize
            menuHeight = contentSize.height
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: screenWidth, height: referenceLoaded ? 80 : 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: screenWidth, height: referenceLoaded ? 80 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return referenceLoaded ? 2 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! ContextMenuCell
            if let reference = reference { cell.configure(withDescription: reference.option.optionMenuMessage) }
            
            let contentSize = collectionView.collectionViewLayout.collectionViewContentSize
            menuHeight = contentSize.height
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: referenceCellReuseIdentifier, for: indexPath) as! ReferenceCell
            if let reference = reference { cell.configureWithReference(text: reference.referenceText) }
            
            let contentSize = collectionView.collectionViewLayout.collectionViewContentSize
            menuHeight = contentSize.height
            return cell
        }
    }
}

extension ReferenceMenu: ContextMenuFooterDelegate {
    func didTapCloseMenu() {
        guard let reference = reference else { return }
        handleDismissMenu()
        delegate?.didTapReference(reference: reference)
    }
}


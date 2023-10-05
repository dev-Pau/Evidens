//
//  ConnectionMenu.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/10/23.
//

import UIKit

private let connectionHeaderCellReuseIdentifier = "ConnectionHeaderCellReuseIdentifier"
private let connectionMenuCellReuseIdentifier = "ConnectionMenuCellReuseIdentifier"
private let connectionMenuFooterReuseIdentifier = "ConnectionMenuFooterReuseIdentifier"

protocol ConnectionMenuDelegate: AnyObject {
    func didTapMessage()
    func didTapConnection()
    func didTapFollow()
}

class ConnectionMenu: NSObject {
    
    weak var delegate: ConnectionMenuDelegate?
    
    private(set) var user: User

    private let blackBackgroundView: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        return view
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
    
    func set(user: User) {
        self.user = user
    }
    
    private let menuYOffset: CGFloat = UIScreen.main.bounds.height
    
    private var screenWidth: CGFloat = 0
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: .leastNonzeroMagnitude)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.layer.cornerRadius = 20
        collectionView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        return collectionView
    }()
                                                
    func showMenu(in view: UIView) {
        screenWidth = view.frame.width
        configureImageSettings(in: view)
        collectionView.reloadData()
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [weak self] in
            
            guard let strongSelf = self else { return }
            strongSelf.blackBackgroundView.alpha = 1
            strongSelf.collectionView.frame = CGRect(x: 0, y: strongSelf.menuYOffset - strongSelf.menuHeight, width: strongSelf.screenWidth, height: strongSelf.menuHeight)
            
        }, completion: nil)
    }
    
    @objc func handleDismissMenu() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 1, options: .curveEaseOut) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.blackBackgroundView.alpha = 0
            strongSelf.collectionView.frame = CGRect(x: 0, y: strongSelf.menuYOffset, width: strongSelf.screenWidth, height: strongSelf.menuHeight)
        }
    }
    
    func configureImageSettings(in view: UIView) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.addSubview(blackBackgroundView)
            window.addSubview(collectionView)
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
        
        collectionView.register(ConnectionHeaderCell.self, forCellWithReuseIdentifier: connectionHeaderCellReuseIdentifier)
        collectionView.register(ConnectionMenuCell.self, forCellWithReuseIdentifier: connectionMenuCellReuseIdentifier)
        collectionView.register(ConnectionMenuFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: connectionMenuFooterReuseIdentifier)
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
    
    init(user: User) {
        self.user = user
        super.init()
        configureCollectionView()
    }
}

extension ConnectionMenu: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: connectionMenuFooterReuseIdentifier, for: indexPath) as!
        ConnectionMenuFooter
        footer.set(user: user)
        footer.delegate = self
        
        let contentSize = collectionView.collectionViewLayout.collectionViewContentSize
        menuHeight = contentSize.height
        
        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: screenWidth, height: 140)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: connectionHeaderCellReuseIdentifier, for: indexPath) as! ConnectionHeaderCell
            cell.set(user: user)
            
            let contentSize = collectionView.collectionViewLayout.collectionViewContentSize
            menuHeight = contentSize.height
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: connectionMenuCellReuseIdentifier, for: indexPath) as! ConnectionMenuCell
            cell.set(user: user)
            
            let contentSize = collectionView.collectionViewLayout.collectionViewContentSize
            menuHeight = contentSize.height
            return cell
        }
    }
}

extension ConnectionMenu: ConnectionMenuFooterDelegate {
    func didTapMessage() {
        delegate?.didTapMessage()
    }
    
    func didTapConnection() {
        delegate?.didTapConnection()
    }
    
    func didTapFollow() {
        delegate?.didTapFollow()
    }
}



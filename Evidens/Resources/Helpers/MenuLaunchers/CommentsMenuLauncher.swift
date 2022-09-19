//
//  CommentsMenuLauncher.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/8/22.
//

import UIKit

private let cellReuseIdentifier = "CommentMenuCellReuseIdentifier"
private let headerReuseIdentifier = "CommentMenuHeaderReuseIdentifier"


protocol CommentsMenuLauncherDelegate: AnyObject {
    func didTapReport(comment: Comment)
    func menuDidDismiss()
}

class CommentsMenuLauncher: NSObject {
    
    var comment: Comment? {
        didSet {
            guard let currentUid = UserDefaults.standard.value(forKey: "uid") as? String, let comment = comment else { return }
            if comment.uid == currentUid {
                configureCollectionViewData(isCurrentUser: true)
            } else {
                self.configureCollectionViewData(isCurrentUser: false)
            }
        }
    }
    
    public var completion: ((Bool) -> (Void))?
    
    weak var delegate: CommentsMenuLauncherDelegate?
    
    private var menuOptionsText: [String] = []
    private var menuOptionsImages: [UIImage] = []

    private let blackBackgroundView: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        return view
    }()

    private var menuHeight: CGFloat = 110
    private let menuYOffset: CGFloat = UIScreen.main.bounds.height
    
    private var screenWidth: CGFloat = 0
    
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
    
    
    func showCommentsSettings(in view: UIView) {
        screenWidth = view.frame.width
        
        configurePostSettings(in: view)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.blackBackgroundView.alpha = 1
            self.collectionView.frame = CGRect(x: 0, y: self.menuYOffset - self.menuHeight, width: self.screenWidth, height: self.menuHeight)
        }
    }
    
    
    @objc func handleDismiss(selectedOption: String?) {
        guard let currentUid = UserDefaults.standard.value(forKey: "uid") as? String, let comment = comment else { return }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.blackBackgroundView.alpha = 0
            self.collectionView.frame = CGRect(x: 0, y: self.menuYOffset, width: self.screenWidth, height: self.menuHeight)
        } completion: { _ in
            if currentUid == comment.uid {
                self.completion!(true)
            } else {
                self.delegate?.didTapReport(comment: comment)
            }
            self.delegate?.menuDidDismiss()
        }
    }
    
    @objc func handleDismissMenu() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.blackBackgroundView.alpha = 0
            self.collectionView.frame = CGRect(x: 0, y: self.menuYOffset, width: self.screenWidth, height: self.menuHeight)
        } completion: { _ in
            self.delegate?.menuDidDismiss()
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
    
    private func configureCollectionViewData(isCurrentUser: Bool) {
       
        if isCurrentUser {
            menuOptionsText = ["Delete comment"]
            menuOptionsImages = [UIImage(systemName: "trash", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!.withRenderingMode(.alwaysOriginal).withTintColor(.red)]
        } else {
            menuOptionsText = ["Report this comment"]
            menuOptionsImages = [UIImage(systemName: "flag.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!.withRenderingMode(.alwaysOriginal).withTintColor(.red)]
        }
        collectionView.reloadData()
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

extension CommentsMenuLauncher: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! PostMenuHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: screenWidth, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuOptionsText.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! PostMenuCell
        cell.set(withText: menuOptionsText[indexPath.row], withImage: menuOptionsImages[indexPath.row])
        cell.backgroundColor = .white

        cell.layer.cornerRadius = 10
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth - 40, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedOption = menuOptionsText[indexPath.row]
        handleDismiss(selectedOption: selectedOption)
    }
}



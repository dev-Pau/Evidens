//
//  HomeOptionsMenuLauncher.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/7/22.
//

import UIKit

private let cellReuseIdentifier = "PostMenuCellReuseIdentifier"
private let headerReuseIdentifier = "PostMenuHeaderReuseIdentifier"


protocol HomeOptionsMenuLauncherDelegate: AnyObject {
    func didTapDeletePost(forPostUid uid: String)
    func didTapEditPost(forPost post: Post)
    func didTapFollowAction(forUid uid: String, isFollowing follow: Bool, forUserFirstName firstName: String)
    func didTapReportPost(forPostUid uid: String)
}

class HomeOptionsMenuLauncher: NSObject {
    
    var post: Post? {
        didSet {
            guard let currentUid = UserDefaults.standard.value(forKey: "uid") as? String, let post = post else { return }
            if post.ownerUid == currentUid {
                configureCollectionViewData(isCurrentUser: true, isFollowed: nil)
            } else {
                UserService.checkIfUserIsFollowed(uid: post.ownerUid) { isFollowed in
                    self.isFollowed = isFollowed
                    self.configureCollectionViewData(isCurrentUser: false, isFollowed: isFollowed)
                }
            }
        }
    }
    
    private let blackBackgroundView: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        return view
    }()
    
    private var isFollowed: Bool = false
    
    private var menuHeight: CGFloat = 160
    
    weak var delegate: HomeOptionsMenuLauncherDelegate?
    

    private let menuYOffset: CGFloat = UIScreen.main.bounds.height
    
    private var screenWidth: CGFloat = 0
    
    private var menuOptionsText: [String] = []
    private var menuOptionsImages: [UIImage] = []
    
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
                                                
    func showImageSettings(in view: UIView) {
        screenWidth = view.frame.width
        
        configureImageSettings(in: view)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blackBackgroundView.alpha = 1
            self.collectionView.frame = CGRect(x: 0, y: self.menuYOffset - self.menuHeight, width: self.screenWidth, height: self.menuHeight)
        }, completion: nil)
    }
    
    
    @objc func handleDismiss(selectedOption: String?) {
        guard let currentUid = UserDefaults.standard.value(forKey: "uid") as? String, let ownerUid = post?.ownerUid, let postId = post?.postId, let firstName = post?.ownerFirstName else { return }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.blackBackgroundView.alpha = 0
            self.collectionView.frame = CGRect(x: 0, y: self.menuYOffset, width: self.screenWidth, height: self.menuHeight)
        } completion: { completed in
            
            if ownerUid == currentUid {
                // User is tapping on property post
                switch selectedOption {
                case self.menuOptionsText[0]:
                    self.delegate?.didTapEditPost(forPost: self.post!)
                case self.menuOptionsText[1]:
                    self.delegate?.didTapDeletePost(forPostUid: postId)
                default:
                    break
                }
            } else {
                switch selectedOption {
                case self.menuOptionsText[0]:
                    self.delegate?.didTapFollowAction(forUid: ownerUid, isFollowing: self.isFollowed, forUserFirstName: firstName)
                case self.menuOptionsText[1]:
                    self.delegate?.didTapReportPost(forPostUid: postId)
                default:
                    break
                }
            }
            
        }
    }
    
    @objc func handleDismissMenu() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.blackBackgroundView.alpha = 0
            self.collectionView.frame = CGRect(x: 0, y: self.menuYOffset, width: self.screenWidth, height: self.menuHeight)
        }
    }

    func configureImageSettings(in view: UIView) {
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
    
    private func configureCollectionViewData(isCurrentUser: Bool, isFollowed: Bool?) {
        //guard let currentUid = UserDefaults.standard.value(forKey: "uid") as? String, let post = post else { return }
        if isCurrentUser {
            menuOptionsText = ["Edit", "Delete"]
            menuOptionsImages = [UIImage(systemName: "gearshape", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!,
                                 UIImage(systemName: "trash", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!.withRenderingMode(.alwaysOriginal).withTintColor(.red)]
            menuHeight = 160
            collectionView.reloadData()
            
        } else {
            guard let isFollowed = isFollowed, let firstName = post?.ownerFirstName else { return }

            let followText = isFollowed ? "Unfollow" : "Follow"
            let followImage = isFollowed ? "xmark.circle.fill" : "plus.circle.fill"
            
            menuOptionsText = [followText + " " + firstName, "Report this post"]
            menuOptionsImages = [UIImage(systemName: followImage, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!, UIImage(systemName: "flag.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!.withRenderingMode(.alwaysOriginal).withTintColor(.red)]
            menuHeight = 160
            collectionView.reloadData()
        }
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

extension HomeOptionsMenuLauncher: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
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

        if indexPath.row == 0 {
            cell.layer.cornerRadius = 10
            cell.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
        
         else if indexPath.row == menuOptionsText.count - 1 {
            cell.layer.cornerRadius = 10
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
         } else {
             cell.layer.cornerRadius = 0
         }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth - 60, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedOption = menuOptionsText[indexPath.row]
        handleDismiss(selectedOption: selectedOption)
    }
}


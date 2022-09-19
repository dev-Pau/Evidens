//
//  CommentCaseViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 25/7/22.
//

import UIKit

private let reuseIdentifier = "CommentCell"

class CommentCaseViewController: UICollectionViewController {
    
    //MARK: - Properties
    
    private var commentMenu = CommentsMenuLauncher()
    
    private var clinicalCase: Case
    private var user: User
    
    private var comments = [Comment]()
    private var ownerComments = [User]()
    
    private lazy var commentInputView: CommentInputAccessoryView = {
        let cv = CommentInputAccessoryView()
        cv.delegate = self
        return cv
    }()
    
    //MARK: - Lifecycle
    
    init(clinicalCase: Case, user: User) {
        self.clinicalCase = clinicalCase
        self.user = user
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 100)
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        commentMenu.delegate = self
        configureCollectionView()
        fetchComments()
    }
    
    override var inputAccessoryView: UIView? {
        get { return commentInputView }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    //Hide tab bar when comment input acccesory view appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    //Show tab bar when comment input acccesory view dissappears
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: - API
    
    func fetchComments() {
        CommentService.fetchCaseComments(forCase: clinicalCase.caseId) { commentsFetched in
            
            self.comments.removeAll()
            // Append the description of the case as comment
            self.comments.append(Comment(dictionary: [
                "anonymous": self.clinicalCase.privacyOptions == .nonVisible ? true : false,
                "comment": self.clinicalCase.caseDescription,
                "timestamp": self.clinicalCase.timestamp,
                "uid": self.user.uid as Any,
                "firstName": self.user.firstName as Any,
                "category": self.user.category.userCategoryString as Any,
                "speciality": self.user.speciality as Any,
                "profession": self.user.profession as Any,
                "lastName": self.user.lastName as Any,
                "isAuthor": true as Bool,
                "isTextFromAuthor": true as Bool,
                "profileImageUrl": self.user.profileImageUrl as Any]))
            
            self.ownerComments.append(User(dictionary: [
                "uid": self.user.uid as Any,
                "firstName": self.user.firstName as Any,
                "lastName": self.user.lastName as Any,
                "profileImageUrl": self.user.profileImageUrl as Any,
                "profession": self.user.profession as Any,
                "category": self.user.category as Any,
                "speciality": self.user.speciality as Any]))
            
            self.comments.append(contentsOf: commentsFetched)
            
            if commentsFetched.count == 0 {
                self.collectionView.reloadData()
                return
            }
            
            self.comments.forEach { comment in
                UserService.fetchUser(withUid: comment.uid) { user in
                    self.ownerComments.append(user)
                    if self.ownerComments.count == self.comments.count {
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                            print(self.comments)
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Helpers
    
    func configureCollectionView() {
        
        if clinicalCase.privacyOptions == .nonVisible {
            commentInputView.profileImageView.image = UIImage(systemName: "hand.raised.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(grayColor)
        } else {
            guard let uid = UserDefaults.standard.value(forKey: "userProfileImageUrl") as? String else { return }
            commentInputView.profileImageView.sd_setImage(with: URL(string: uid))
        }
        
        navigationItem.title = "Comments"
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        view.addSubview(collectionView)

        //To dismiss the keyboard and hide when scrolling
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        
    }
}


//MARK: - UICollectionViewDataSource

extension CommentCaseViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCell
        
        cell.authorButton.isHidden = true

        cell.delegate = self
        cell.viewModel = CommentViewModel(comment: comments[indexPath.row])
        
        let userIndex = ownerComments.firstIndex { user in
            return user.uid == comments[indexPath.row].uid
        }!
        
        cell.set(user: ownerComments[userIndex])
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}




//MARK: - CommentInputAccesoryViewDelegate

extension CommentCaseViewController: CommentInputAccessoryViewDelegate {
    func inputView(_ inputView: CommentInputAccessoryView, wantsToUploadComment comment: String) {
        //Get user from MainTabController
        guard let tab = self.tabBarController as? MainTabController else { return }
        guard let currentUser = tab.user else { return }
        //Show loader to block user interactions
        
        //Upload commento to Firebase
        
        if clinicalCase.ownerUid == currentUser.uid && clinicalCase.privacyOptions == .nonVisible {
            // Owner of the anonymous case
            CommentService.uploadAnonymousComment(comment: comment, clinicalCase: clinicalCase, user: currentUser) { _ in
                // As comment is anonymous, there's no need to upload the comment to recent comments
                
            }
        } else {
            CommentService.uploadCaseComment(comment: comment, clinicalCase: clinicalCase, user: currentUser) { ids in
                //Unshow loader
                let commentUid = ids[0]
                let caseUid = ids[1]
                
                DatabaseManager.shared.uploadRecentComments(withCommentUid: commentUid, withRefUid: caseUid, title: self.clinicalCase.caseTitle, comment: comment, type: .clinlicalCase, withTimestamp: Date()) { uploaded in }
                
                self.clinicalCase.numberOfComments += 1
                inputView.clearCommentTextView()
                
                
                let isAuthor = currentUser.uid == self.clinicalCase.ownerUid ? true : false
                
                self.comments.append(Comment(dictionary: [
                    "comment": comment,
                    "uid": currentUser.uid as Any,
                    "id": commentUid as Any,
                    "timestamp": "Now" as Any,
                    "firstName": currentUser.firstName as Any,
                    "category": currentUser.category.userCategoryString as Any,
                    "speciality": currentUser.speciality as Any,
                    "profession": currentUser.profession as Any,
                    "lastName": currentUser.lastName as Any,
                    "isAuthor": isAuthor as Any,
                    "profileImageUrl": currentUser.profileImageUrl as Any]))
                
                self.ownerComments.append(User(dictionary: [
                    "uid": currentUser.uid as Any,
                    "firstName": currentUser.firstName as Any,
                    "lastName": currentUser.lastName as Any,
                    "profileImageUrl": currentUser.profileImageUrl as Any,
                    "profession": currentUser.profession as Any,
                    "category": currentUser.category as Any,
                    "speciality": currentUser.speciality as Any]))
                
                
                let indexPath = IndexPath(item: self.comments.count - 1, section: 0)
                self.collectionView.reloadData()
                self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
                
                NotificationService.uploadNotification(toUid: self.clinicalCase.ownerUid, fromUser: currentUser, type: .commentCase, clinicalCase: self.clinicalCase, withComment: comment)
            }
        }
    }
}

extension CommentCaseViewController: CommentCellDelegate {
    func didTapProfile(forUser user: User) {
        let controller = UserProfileViewController(user: user)
        
        let backButton = UIBarButtonItem()
        backButton.title = ""
        backButton.tintColor = .black
        navigationItem.backBarButtonItem = backButton
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func didTapComment(_ cell: UICollectionViewCell, forComment comment: Comment) {
        commentMenu.comment = comment
        commentMenu.showCommentsSettings(in: view)
        commentInputView.commentTextView.resignFirstResponder()
        commentInputView.isHidden = true
        
        commentMenu.completion = { delete in
            
            if let indexPath = self.collectionView.indexPath(for: cell) {
                self.deleteCommentAlert {
                    CommentService.deleteCaseComment(forCase: self.clinicalCase, forCommentUid: comment.id) { deleted in
                        if deleted {
                            DatabaseManager.shared.deleteRecentComment(forCommentId: comment.id)
                            
                            self.collectionView.performBatchUpdates {
                                self.comments.remove(at: indexPath.item)
                                self.ownerComments.remove(at: indexPath.item)
                                self.collectionView.deleteItems(at: [indexPath])
                            }
                            let popupView = METopPopupView(title: "Comment deleted", image: "trash")
                            popupView.showTopPopup(inView: self.view)
                        }
                        else {
                            print("couldnt remove comment")
                        }
                    }
                }
            }
        }
    }
}

extension CommentCaseViewController: CommentsMenuLauncherDelegate {
    
    func didTapReport(comment: Comment) {
        reportCommentAlert {
            DatabaseManager.shared.reportCaseComment(forCommentId: comment.id) { reported in
                if reported {
                    let popupView = METopPopupView(title: "Comment reported", image: "exclamationmark.bubble")
                    popupView.showTopPopup(inView: self.view)
                }
            }
        }
    }
        
    func menuDidDismiss() {
        inputAccessoryView?.isHidden = false
    }
}

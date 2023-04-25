//
//  CommentCaseViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 25/7/22.
//

import UIKit
import Firebase

private let commentCellReuseIdentifier = "CommentCellReuseIdentifier"
private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"

protocol CommentCaseViewControllerDelegate: AnyObject {
    func didCommentCase(clinicalCase: Case, user: User, comment: Comment)
    func didDeleteCaseComment(clinicalCase: Case, comment: Comment)
}

class CommentCaseViewController: UICollectionViewController {
    
    //MARK: - Properties

    weak var delegate: CommentCaseViewControllerDelegate?
    
    private var clinicalCase: Case
    private var currentUser: User
    private var user: User
    private var type: Comment.CommentType
    private var commentsLoaded: Bool = false
    private var lastCommentSnapshot: QueryDocumentSnapshot?
    
    private var comments = [Comment]()
    private var users = [User]()
    
    private lazy var commentInputView: CommentInputAccessoryView = {
        let cv = CommentInputAccessoryView()
        cv.accessoryViewDelegate = self
        return cv
    }()
    
    //MARK: - Lifecycle
    
    init(clinicalCase: Case, user: User, type: Comment.CommentType, currentUser: User) {
        self.clinicalCase = clinicalCase
        self.user = user
        self.type = type
        self.currentUser = currentUser
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: .leastNonzeroMagnitude)
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureCollectionView()
        fetchComments()
    }
    
    override var inputAccessoryView: UIView? {
        get { return commentInputView }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    //MARK: - API
    
    func fetchComments() {
        comments.removeAll()
        // Append the title of the case as comment
        comments.append(Comment(dictionary: [
            "anonymous": clinicalCase.privacyOptions == .nonVisible ? true : false,
            "comment": clinicalCase.caseTitle as String,
            "timestamp": clinicalCase.timestamp as Any,
            "uid": user.uid as Any,
            "isAuthor": true as Bool,
            "isTextFromAuthor": true as Bool as Any]))
        
        users.append(User(dictionary: [
            "uid": user.uid as Any,
            "firstName": user.firstName as Any,
            "lastName": user.lastName as Any,
            "profileImageUrl": user.profileImageUrl as Any,
            "profession": user.profession as Any,
            "category": user.category.rawValue as Any,
            "speciality": user.speciality as Any]))
        
        CommentService.fetchCaseComments(forCase: clinicalCase, forType: type, lastSnapshot: nil) { snapshot in
            if snapshot.isEmpty {
                // No comments uploaded
                self.commentsLoaded = true
                self.collectionView.reloadData()
                return
            } else {
                // Found comments
                self.lastCommentSnapshot = snapshot.documents.last
                let caseComments = snapshot.documents.map { Comment(dictionary: $0.data()) }
                self.comments.append(contentsOf: caseComments)
                let uids = caseComments.map( { $0.uid })
                UserService.fetchUsers(withUids: uids) { users in
                    self.users.append(contentsOf: users)
                    self.commentsLoaded = true
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    //MARK: - Helpers
    
    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: commentCellReuseIdentifier)
        
        view.addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
    }
    
    private func configureUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
        
        if clinicalCase.privacyOptions == .nonVisible {
            commentInputView.profileImageView.image = UIImage(named: "user.profile.privacy")
        } else {
            guard let imageUrl = UserDefaults.standard.value(forKey: "userProfileImageUrl") as? String, imageUrl != "" else { return }
            commentInputView.profileImageView.sd_setImage(with: URL(string: imageUrl))
        }
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            getMoreComments()
        }
    }
    
    private func getMoreComments() {
        CommentService.fetchCaseComments(forCase: clinicalCase, forType: type, lastSnapshot: lastCommentSnapshot) { snapshot in
            guard !snapshot.isEmpty else { return }
            self.lastCommentSnapshot = snapshot.documents.last
            let newComments = snapshot.documents.map( { Comment(dictionary: $0.data()) })
            let newOwnerUids = newComments.map({ $0.uid })
            UserService.fetchUsers(withUids: newOwnerUids) { newUsers in
                self.comments.append(contentsOf: newComments)
                self.users.append(contentsOf: newUsers)
                self.collectionView.reloadData()
            }
        }
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}


//MARK: - UICollectionViewDataSource

extension CommentCaseViewController: UICollectionViewDelegateFlowLayout {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return commentsLoaded ? comments.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return commentsLoaded ? CGSize.zero : CGSize(width: view.frame.width, height: 55)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentCellReuseIdentifier, for: indexPath) as! CommentCell
        
        cell.authorButton.isHidden = true

        cell.delegate = self
        cell.viewModel = CommentViewModel(comment: comments[indexPath.row])
        
        let userIndex = users.firstIndex { user in
            return user.uid == comments[indexPath.row].uid
        }!
        
        cell.set(user: users[userIndex])
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
        return header
    }
}

extension CommentCaseViewController: CommentCellDelegate {
    func didTapComment(_ cell: UICollectionViewCell, forComment comment: Comment, action: Comment.CommentOptions) {
        switch action {
        case .report:
            reportCommentAlert {
                DatabaseManager.shared.reportCaseComment(forCommentId: comment.id) { reported in
                    if reported {
                        let popupView = METopPopupView(title: "Comment reported", image: "checkmark.circle.fill", popUpType: .regular)
                        popupView.showTopPopup(inView: self.view)
                    }
                }
            }
        case .delete:
            if let indexPath = self.collectionView.indexPath(for: cell) {
                self.deleteCommentAlert {
                    CommentService.deleteCaseComment(forCase: self.clinicalCase, forCommentUid: comment.id) { deleted in
                        if deleted {
                            DatabaseManager.shared.deleteRecentComment(forCommentId: comment.id)
                            
                            self.collectionView.performBatchUpdates {
                                self.comments.remove(at: indexPath.item)
                                self.users.remove(at: indexPath.item)
                                self.collectionView.deleteItems(at: [indexPath])
                            }
                            self.delegate?.didDeleteCaseComment(clinicalCase: self.clinicalCase, comment: comment)
                            let popupView = METopPopupView(title: "Comment deleted", image: "checkmark.circle.fill", popUpType: .regular)
                            popupView.showTopPopup(inView: self.view)
                        }
                        else {
                            print("couldnt remove comment")
                        }
                    }
                }
            }
        case .back:
            navigationController?.popViewController(animated: true)
        }
    }
    
    func didTapProfile(forUser user: User) {
        let controller = UserProfileViewController(user: user)
        
        let backButton = UIBarButtonItem()
        backButton.title = ""
        backButton.tintColor = .label
        navigationItem.backBarButtonItem = backButton
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: - CommentInputAccesoryViewDelegate

extension CommentCaseViewController: CommentInputAccessoryViewDelegate {
    func didTapAddReference() {
        
    }
    
    func inputView(_ inputView: CommentInputAccessoryView, wantsToUploadComment comment: String) {
        //Upload commento to Firebase
        if clinicalCase.ownerUid == currentUser.uid && clinicalCase.privacyOptions == .nonVisible {
            // Owner of the anonymous case. Upload the comments as Anonymous & prevent from uploading to recent user comments
            CommentService.uploadAnonymousComment(comment: comment, clinicalCase: clinicalCase, user: currentUser, type: type) { ids in
                // As comment is anonymous, there's no need to upload the comment to recent comments
                let commentUid = ids[0]
                let _ = ids[1]
                
                self.clinicalCase.numberOfComments += 1
                inputView.clearCommentTextView()

                let newComment = Comment(dictionary: [
                    "comment": comment,
                    "uid": self.currentUser.uid as Any,
                    "id": commentUid as Any,
                    "timestamp": "Now" as Any,
                    "isAuthor": true as Any,
                    "anonymous": true as Any as Any])
                
                self.comments.insert(newComment, at: 1)
                
                let indexPath = IndexPath(item: 1, section: 0)
                self.collectionView.insertItems(at: [indexPath])
                self.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)

                self.delegate?.didCommentCase(clinicalCase: self.clinicalCase, user: self.user, comment: newComment)

            }
        } else {
            CommentService.uploadCaseComment(comment: comment, clinicalCase: clinicalCase, user: currentUser, type: type) { ids in
                let commentUid = ids[0]
                let caseUid = ids[1]
                
                if self.type == .regular {
                    DatabaseManager.shared.uploadRecentComments(withCommentUid: commentUid, withRefUid: caseUid, title: self.clinicalCase.caseTitle, comment: comment, type: .clinlicalCase, withTimestamp: Date()) { uploaded in }
                }
               
                self.clinicalCase.numberOfComments += 1
                inputView.clearCommentTextView()
                
                
                let isAuthor = self.currentUser.uid == self.clinicalCase.ownerUid ? true : false
                
                let newComment = Comment(dictionary: [
                    "comment": comment,
                    "uid": self.currentUser.uid as Any,
                    "id": commentUid as Any,
                    "timestamp": "Now" as Any,
                    "isAuthor": isAuthor as Any as Any])
                
                self.users.append(User(dictionary: [
                    "uid": self.currentUser.uid as Any,
                    "firstName": self.currentUser.firstName as Any,
                    "lastName": self.currentUser.lastName as Any,
                    "profileImageUrl": self.currentUser.profileImageUrl as Any,
                    "profession": self.currentUser.profession as Any,
                    "category": self.currentUser.category.rawValue as Any,
                    "speciality": self.currentUser.speciality as Any]))
                
                self.comments.insert(newComment, at: 1)
                
                let indexPath = IndexPath(item: 1, section: 0)
                self.collectionView.insertItems(at: [indexPath])
                self.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
                
                self.delegate?.didCommentCase(clinicalCase: self.clinicalCase, user: self.currentUser, comment: newComment)
                
                NotificationService.uploadNotification(toUid: self.clinicalCase.ownerUid, fromUser: self.currentUser, type: .commentCase, clinicalCase: self.clinicalCase, withCommentId: commentUid)
            }
        }
    }
}

//
//  CommentViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 25/11/21.
//

import UIKit

private let reuseIdentifier = "CommentCell"

class CommentPostViewController: UICollectionViewController {
    
    //MARK: - Properties
    
    private var post: Post
    private var comments = [Comment]()
    
    private var commentMenu = CommentsMenuLauncher()
 
    private lazy var commentInputView: CommentInputAccessoryView = {
        let cv = CommentInputAccessoryView()
        cv.delegate = self
        return cv
    }()
    
    private lazy var emptyCommentLabel: UILabel = {
        let label = UILabel()
        label.text = "No comments yet."
        label.textAlignment = .center
        label.textColor = .black
        label.font = .systemFont(ofSize: 21, weight: .bold)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var startTheConversationLabel: UILabel = {
        let label = UILabel()
        label.text = "Start the conversation."
        label.textAlignment = .center
        label.textColor = grayColor
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Lifecycle
    
    init(post: Post) {
        self.post = post
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
        CommentService.fetchComments(forPost: post.postId) { comments in
            self.comments.removeAll()
            // If user post has text, append it as first element
            if !self.post.postText.isEmpty {
                self.comments.append(Comment(dictionary: [
                    "comment": self.post.postText,
                    "uid": self.post.ownerUid,
                    "timestamp": self.post.timestamp,
                    "firstName": self.post.ownerFirstName as Any,
                    "category": self.post.ownerCategory as Any,
                    "speciality": self.post.ownerSpeciality as Any,
                    "profession": self.post.ownerProfession as Any,
                    "lastName": self.post.ownerLastName as Any,
                    "profileImageUrl": self.post.ownerImageUrl as Any]))
            }
            // Append the fetched comments
            self.comments.append(contentsOf: comments)
            // Post has no text from the owner & no comments
            if comments.isEmpty && self.post.postText.isEmpty {
                self.emptyCommentLabel.isHidden = false
                self.startTheConversationLabel.isHidden = false
                self.collectionView.isHidden = true
                return
            }
            self.emptyCommentLabel.isHidden = true
            self.startTheConversationLabel.isHidden = true
            self.collectionView.isHidden = false
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    //MARK: - Helpers
    
    func configureCollectionView() {
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
    
    private func configureUI() {
        
        guard let uid = UserDefaults.standard.value(forKey: "userProfileImageUrl") as? String else { return }
        commentInputView.profileImageView.sd_setImage(with: URL(string: uid))
        
        view.addSubviews(emptyCommentLabel, startTheConversationLabel)
        NSLayoutConstraint.activate([
            emptyCommentLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            emptyCommentLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startTheConversationLabel.topAnchor.constraint(equalTo: emptyCommentLabel.bottomAnchor, constant: 10),
            startTheConversationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}


//MARK: - UICollectionViewDataSource

extension CommentPostViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCell
        cell.ownerUid = post.ownerUid
        cell.viewModel = CommentViewModel(comment: comments[indexPath.row])
        cell.delegate = self
        return cell
        
    }
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension CommentPostViewController: CommentCellDelegate {
    
    func didTapProfile(forUid uid: String) {
        UserService.fetchUser(withUid: uid) { user in
            let controller = UserProfileViewController(user: user)
            
            let backButton = UIBarButtonItem()
            backButton.title = ""
            backButton.tintColor = .black
            self.navigationItem.backBarButtonItem = backButton
                    
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func didTapComment(_ cell: UICollectionViewCell, forComment comment: Comment) {
        commentMenu.comment = comment
        commentMenu.showCommentsSettings(in: view)
        commentInputView.commentTextView.resignFirstResponder()
        commentInputView.isHidden = true
        
        commentMenu.completion = { delete in
         
            if let indexPath = self.collectionView.indexPath(for: cell) {
                self.deleteCommentAlert {
                    CommentService.deletePostComment(forPost: self.post, forCommentUid: comment.id) { deleted in
                        if deleted {
                            DatabaseManager.shared.deleteRecentComment(forCommentId: comment.id)
                            
                            
                            self.collectionView.performBatchUpdates {
                                self.comments.remove(at: indexPath.item)
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

extension CommentPostViewController: CommentsMenuLauncherDelegate {
    
    func didTapReport(comment: Comment) {
        
    }
    
    func menuDidDismiss() {
        inputAccessoryView?.isHidden = false
    }
}


//MARK: - CommentInputAccesoryViewDelegate

extension CommentPostViewController: CommentInputAccessoryViewDelegate {
    func inputView(_ inputView: CommentInputAccessoryView, wantsToUploadComment comment: String) {
        
        //Get user from MainTabController
        guard let tab = self.tabBarController as? MainTabController else { return }
        guard let currentUser = tab.user else { return }
        
        //Show loader to block user interactions
        self.view.isUserInteractionEnabled = false
        //Upload commento to Firebase
        CommentService.uploadPostComment(comment: comment, post: post, user: currentUser) { ids in
            //Unshow loader
            let commentUid = ids[0]
            let postUid = ids[1]
            
            DatabaseManager.shared.uploadRecentComments(withCommentUid: commentUid, withRefUid: postUid, title: "", comment: comment, type: .post, withTimestamp: Date()) { uploaded in
                print("Comment uploaded to realtime recent comments")
            }
            
            
            
            self.post.numberOfComments += 1
            inputView.clearCommentTextView()
            
            let indexPath = IndexPath(item: self.comments.count - 1, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
            
            NotificationService.uploadNotification(toUid: self.post.ownerUid, fromUser: currentUser, type: .commentPost, post: self.post, withComment: comment)
            self.view.isUserInteractionEnabled = true
            //self.view.activityStopAnimating()
        }
    }
}

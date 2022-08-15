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
    
    private var clinicalCase: Case
    private var comments = [Comment]()
 
    private lazy var commentInputView: CommentInputAccessoryView = {
        let cv = CommentInputAccessoryView()
        cv.delegate = self
        return cv
    }()
        
    //MARK: - Lifecycle
    
    init(clinicalCase: Case) {
        self.clinicalCase = clinicalCase
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
        CommentService.fetchCaseComments(forCase: clinicalCase.caseId) { comments in
            self.comments.removeAll()
            // Append the description of the case as comment
            self.comments.append(Comment(dictionary: [
                "anonymous": self.clinicalCase.privacyOptions == .nonVisible ? true : false,
                "comment": self.clinicalCase.caseDescription,
                "timestamp": self.clinicalCase.timestamp,
                "uid": self.clinicalCase.ownerUid,
                "firstName": self.clinicalCase.ownerFirstName as Any,
                "category": self.clinicalCase.ownerCategory.userCategoryString as Any,
                "speciality": self.clinicalCase.ownerSpeciality as Any,
                "profession": self.clinicalCase.ownerProfession as Any,
                "lastName": self.clinicalCase.ownerLastName as Any,
                "profileImageUrl": self.clinicalCase.ownerImageUrl as Any]))
            
            // Append the fetched comments
            self.comments.append(contentsOf: comments)
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
}


//MARK: - UICollectionViewDataSource

extension CommentCaseViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCell
        cell.ownerUid = clinicalCase.ownerUid
        cell.viewModel = CommentViewModel(comment: comments[indexPath.row])
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
                
                DatabaseManager.shared.uploadRecentComments(withCommentUid: commentUid, withRefUid: caseUid, title: self.clinicalCase.caseTitle, comment: comment, type: .clinlicalCase, withTimestamp: Date()) { uploaded in
                    print("Comment uploaded to realtime recent comments")
                    NotificationService.uploadNotification(toUid: self.clinicalCase.ownerUid, fromUser: currentUser, type: .commentCase, clinicalCase: self.clinicalCase, withComment: comment)
                }
            }
        }
        
        self.clinicalCase.numberOfComments += 1
        inputView.clearCommentTextView()
        
        let indexPath = IndexPath(item: self.comments.count - 1, section: 0)
        self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
        
        
        
        //self.view.activityStopAnimating()
    }
}

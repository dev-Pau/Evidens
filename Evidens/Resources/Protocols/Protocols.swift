//
//  Protocols.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/10/21.
//

import UIKit
import CoreData

protocol FormViewModel {
    func updateForm()
}

protocol PasswordViewModel {
    var formIsValid: Bool { get }
}

protocol AuthenticationViewModel {
    var formIsValid: Bool { get }
}

protocol HomeCellDelegate: AnyObject {
    func cell(_ cell: UICollectionViewCell, wantsToShowCommentsFor post: Post, forAuthor user: User)
    func cell(_ cell: UICollectionViewCell, didLike post: Post)
    func cell(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User)
    func cell(didTapMenuOptionsFor post: Post, option: PostMenu)
    func cell(_ cell: UICollectionViewCell, didBookmark post: Post)
    func cell(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int)
    func cell(wantsToSeeLikesFor post: Post)
    func cell(_ cell: UICollectionViewCell, wantsToSeePost post: Post, withAuthor user: User)
    func cell(wantsToSeeHashtag hashtag: String)
}

protocol CaseCellDelegate: AnyObject {
    func clinicalCase(wantsToSeeLikesFor clinicalCase: Case)
    func clinicalCase(wantsToShowCommentsFor clinicalCase: Case, forAuthor user: User)
    func clinicalCase(_ cell: UICollectionViewCell, didLike clinicalCase: Case)
    func clinicalCase(_ cell: UICollectionViewCell, didBookmark clinicalCase: Case)
    func clinicalCase(didTapMenuOptionsFor clinicalCase: Case, option: CaseMenu)
    func clinicalCase(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User)
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeUpdatesForCase clinicalCase: Case)
    func clinicalCase(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int)
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeCase clinicalCase: Case, withAuthor user: User?)
    func clinicalCase(wantsToSeeHashtag hashtag: String)
}

protocol HomeCellProtocol: UICollectionViewCell {
    var viewModel: PostViewModel? { get set }
}

protocol CaseCellProtocol: UICollectionViewCell {
    var viewModel: CaseViewModel? { get set }
}

protocol NotificationCellDelegate: AnyObject {
    func cell(_ cell: UICollectionViewCell, wantsToConnect uid: String)
    func cell(_ cell: UICollectionViewCell, wantsToIgnore uid: String)
    func cell(_ cell: UICollectionViewCell, wantsToSeeContentFor notification: Notification)
    func cell(_ cell: UICollectionViewCell, wantsToViewProfile uid: String)
    func cell(_ cell: UICollectionViewCell, didPressThreeDotsFor notification: Notification, option: NotificationMenu)
}

protocol PrimaryScrollViewDelegate: AnyObject {
    func enable()
    func disable()
}

protocol PresentReviewAlertContentGroupDelegate: AnyObject {
    func wantsToSeePost(post: Post, user: User)
    func wantsToSeeProfile(user: User)
}

protocol MessageCellDelegate: AnyObject {
    func didTapMenuOption(message: Message, _ option: MessageMenu)
}

protocol BookmarksCellDelegate: AnyObject {
    func cell(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User)
}


protocol NetworkDelegate: AnyObject {
    func didBecomeConnected()
}

//MARK: - Post Changes

protocol PostChangesDelegate: AnyObject {
    func postDidChangeLike(postId: String, didLike: Bool)
    func postDidChangeBookmark(postId: String, didBookmark: Bool)
    func postDidChangeComment(postId: String, path: [String], comment: Comment, action: CommentAction)
    func postDidChangeVisible(postId: String)
}

//MARK: - Detailed Post Changes

protocol PostDetailedChangesDelegate: AnyObject {
    func postDidChangeCommentLike(postId: String, path: [String], commentId: String, owner: String, didLike: Bool)
}

//MARK: - Case Changes

protocol CaseChangesDelegate: AnyObject {
    func caseDidChangeLike(caseId: String, didLike: Bool)
    func caseDidChangeBookmark(caseId: String, didBookmark: Bool)
    func caseDidChangeComment(caseId: String, path: [String], comment: Comment, action: CommentAction)
    func caseDidChangeVisible(caseId: String)
}

//MARK: - Detailed Case Changes

protocol CaseDetailedChangesDelegate: AnyObject {
    func caseDidChangeCommentLike(caseId: String, path: [String], commentId: String, owner: String, didLike: Bool, anonymous: Bool)
}

protocol UserFollowDelegate: AnyObject {
    func userDidChangeFollow(uid: String, didFollow: Bool)
}

protocol UserConnectDelegate: AnyObject {
    func userDidChangeConnection(uid: String, phase: ConnectPhase)
}

// MARK: - Core Data

protocol CoreDataStackManager {
    func setupCoordinator(forUserId userId: String)
    func coordinator(forUserId userId: String) -> NSPersistentContainer?
    func reset()
}

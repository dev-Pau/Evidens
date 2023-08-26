//
//  Protocols.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/10/21.
//

import UIKit


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
    func clinicalCase(_ cell: UICollectionViewCell, didTapMenuOptionsFor clinicalCase: Case, option: CaseMenu)
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
    func cell(_ cell: UICollectionViewCell, wantsToFollow uid: String)
    func cell(_ cell: UICollectionViewCell, wantsToUnfollow uid: String)
    func cell(_ cell: UICollectionViewCell, wantsToViewPost post: Post?)
    func cell(_ cell: UICollectionViewCell, wantsToViewCase clinicalCase: Case?)
    func cell(_ cell: UICollectionViewCell, wantsToViewProfile uid: String)
    func cell(_ cell: UICollectionViewCell, wantsToSeeFollowingDetailsForNotification: Notification)
    func cell(_ cell: UICollectionViewCell, didPressThreeDotsFor notification: Notification, option: NotificationMenu)
}

protocol DisablePanGestureDelegate: AnyObject {
    func disablePanGesture()
    func disableRightPanGesture()
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
    func postDidChangeComment(postId: String, comment: Comment, action: CommentAction)
    func postDidChangeVisible(postId: String)
}

//MARK: - Detailed Post Changes

protocol PostDetailedChangesDelegate: AnyObject {
    func postDidChangeComment(postId: String, comment: Comment, action: CommentAction)
    func postDidChangeCommentLike(postId: String, commentId: String, didLike: Bool)
    
    func postDidChangeReplyLike(postId: String, commentId: String, replyId: String, didLike: Bool)
    func postDidChangeReply(postId: String, commentId: String, reply: Comment, action: CommentAction)
}

//MARK: - Case Changes

protocol CaseChangesDelegate: AnyObject {
    func caseDidChangeLike(caseId: String, didLike: Bool)
    func caseDidChangeBookmark(caseId: String, didBookmark: Bool)
    func caseDidChangeComment(caseId: String, comment: Comment, action: CommentAction)
}

//MARK: - Detailed Case Changes

protocol CaseDetailedChangesDelegate: AnyObject {
    func caseDidChangeComment(caseId: String, comment: Comment, action: CommentAction)
    func caseDidChangeCommentLike(caseId: String, commentId: String, didLike: Bool)
    
    func caseDidChangeReplyLike(caseId: String, commentId: String, replyId: String, didLike: Bool)
    func caseDidChangeReply(caseId: String, commentId: String, reply: Comment, action: CommentAction)
}

protocol UserFollowDelegate: AnyObject {
    func userDidChangeFollow(uid: String, didFollow: Bool)
}

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
    //func cell(_ cell: UICollectionViewCell, didPressThreeDotsFor post: Post, forAuthor user: User)
    func cell(_ cell: UICollectionViewCell, didTapMenuOptionsFor post: Post, option: Post.PostMenuOptions)
    func cell(_ cell: UICollectionViewCell, didBookmark post: Post)
    func cell(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int)
    func cell(wantsToSeeLikesFor post: Post)
    func cell(_ cell: UICollectionViewCell, wantsToSeePost post: Post, withAuthor user: User)
}

protocol CaseCellDelegate: AnyObject {
    func clinicalCase(wantsToSeeLikesFor clinicalCase: Case)
    func clinicalCase(wantsToShowCommentsFor clinicalCase: Case, forAuthor user: User)
    func clinicalCase(_ cell: UICollectionViewCell, didLike clinicalCase: Case)
    func clinicalCase(_ cell: UICollectionViewCell, didBookmark clinicalCase: Case)
    func clinicalCase(_ cell: UICollectionViewCell, didTapMenuOptionsFor clinicalCase: Case, option: Case.CaseMenuOptions)
    //func clinicalCase(_ cell: UICollectionViewCell, didPressThreeDotsFor clinicalCase: Case)
    func clinicalCase(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User)
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeUpdatesForCase clinicalCase: Case)
    func clinicalCase(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int)
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeCase clinicalCase: Case, withAuthor user: User)
}

protocol NotificationCellDelegate: AnyObject {
    func cell(_ cell: UICollectionViewCell, wantsToFollow uid: String)
    func cell(_ cell: UICollectionViewCell, wantsToUnfollow uid: String)
    func cell(_ cell: UICollectionViewCell, wantsToViewPost postId: String)
    func cell(_ cell: UICollectionViewCell, wantsToViewCase caseId: String)
    func cell(_ cell: UICollectionViewCell, wantsToViewProfile uid: String)
    func cell(_ cell: UICollectionViewCell, wantsToSeeFollowingDetailsForNotification: Notification)
    func cell(_ cell: UICollectionViewCell, didPressThreeDotsFor notification: Notification, option: Notification.NotificationMenuOptions)
}

protocol DisablePanGestureDelegate: AnyObject {
    func disablePanGesture()
    func disableRightPanGesture()
}


protocol ReviewContentGroupDelegate: AnyObject {
    func didTapAcceptContent(contentId: String, type: ContentGroup.GroupContentType)
    func didTapCancelContent(contentId: String, type: ContentGroup.GroupContentType)
}

protocol PresentReviewAlertContentGroupDelegate: AnyObject {
    //func showAcceptContentPopUp(type: ContentGroup.GroupContentType)
    //func didCancelContent(type: ContentGroup.GroupContentType)
    //func showDeleteAlertController(type: ContentGroup.GroupContentType, contentId: String)
    func wantsToSeePost(post: Post, user: User)
    func wantsToSeeProfile(user: User)
}

protocol DetailsContentReviewDelegate: AnyObject {
    func didTapAcceptContent(type: ContentGroup.GroupContentType, contentId: String)
    func didTapCancelContent(type: ContentGroup.GroupContentType, contentId: String)
}



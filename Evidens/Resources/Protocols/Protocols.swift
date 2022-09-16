//
//  Protocols.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/10/21.
//

import UIKit

protocol HomeCellDelegate: AnyObject {
    func cell(_ cell: UICollectionViewCell, wantsToShowCommentsFor post: Post, forAuthor: User)
    func cell(_ cell: UICollectionViewCell, didLike post: Post)
    func cell(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User)
    func cell(_ cell: UICollectionViewCell, didPressThreeDotsFor post: Post, forAuthor user: User)
    func cell(_ cell: UICollectionViewCell, didBookmark post: Post)
    func cell(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int)
    func cell(wantsToSeeLikesFor post: Post)
    func cell(_ cell: UICollectionViewCell, wantsToSeePost post: Post, withAuthor user: User)
}

protocol CaseCellDelegate: AnyObject {
    func clinicalCase(wantsToSeeLikesFor clinicalCase: Case)
    func clinicalCase(wantsToShowCommentsFor clinicalCase: Case)
    func clinicalCase(_ cell: UICollectionViewCell, didLike clinicalCase: Case)
    func clinicalCase(_ cell: UICollectionViewCell, didBookmark clinicalCase: Case)
    func clinicalCase(_ cell: UICollectionViewCell, didPressThreeDotsFor clinicalCase: Case)
    func clinicalCase(_ cell: UICollectionViewCell, wantsToShowProfileFor uid: String)
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeUpdatesForCase clinicalCase: Case)
    func clinicalCase(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int)
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeCase clinicalCase: Case)
}

protocol NotificationCellDelegate: AnyObject {
    func cell(_ cell: UICollectionViewCell, wantsToFollow uid: String, firstName: String)
    func cell(_ cell: UICollectionViewCell, wantsToUnfollow uid: String, firstName: String)
    func cell(_ cell: UICollectionViewCell, wantsToViewPost postId: String)
    func cell(_ cell: UICollectionViewCell, wantsToViewCase caseId: String)
    func cell(_ cell: UICollectionViewCell, wantsToViewProfile uid: String)
    func cell(_ cell: UICollectionViewCell, didPressThreeDotsFor notification: Notification)
}

protocol DisablePanGestureDelegate: AnyObject {
    func disablePanGesture()
}



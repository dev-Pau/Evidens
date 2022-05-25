//
//  Protocols.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/10/21.
//

import UIKit

protocol HomeViewControllerDelegate {
    func handleMenuToggle()
}


protocol HomeCellDelegate: AnyObject {
    func cell(_ cell: UICollectionViewCell, wantsToShowCommentsFor post: Post)
    func cell(_ cell: UICollectionViewCell, didLike post: Post)
    func cell(_ cell: UICollectionViewCell, wantsToShowProfileFor uid: String)
    func cell(_ cell: UICollectionViewCell, didPressThreeDotsFor post: Post, withAction action: String)
    func cell(_ cell: UICollectionViewCell, didBookmark post: Post)
}

//
//  ProfileHeaderViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/10/21.
//

import UIKit

struct ProfileHeaderViewModel {
    var user: User
    
    var fullName: String {
        return user.name()
    }
    
    var details: String {
        return user.details()
    }
    
    var firstName: String {
        return user.firstName!
    }

    var followText: String {
        return user.isCurrentUser ? AppStrings.Profile.editProfile : user.isFollowed ? AppStrings.Alerts.Actions.following : AppStrings.Alerts.Actions.follow
    }
    
    var followBackgroundColor: UIColor {
        return user.isCurrentUser || user.isFollowed ? .systemBackground : .label
    }
    
    var followTextColor: UIColor {
        return user.isCurrentUser || user.isFollowed ? .label : .systemBackground
    }
    
    var followButtonBorderColor: UIColor {
        return user.isCurrentUser || user.isFollowed ? .quaternarySystemFill : .label
    }
    
    var followButtonBorderWidth: CGFloat {
        return user.isFollowed || user.isCurrentUser ? 1 : 0
    }
    
    var followers: Int {
        return user.stats.followers
    }
    
    var following: Int {
        return user.stats.following
    }
    
    var followingFollowersText: NSAttributedString {
        return followingUserStats(valueFollowers: followers, valueFollowing: following)
    }

    func followersText(valueFollowers: Int) -> NSAttributedString {
        let followers = String(valueFollowers)

        let aString = NSMutableAttributedString(string: followers + " " + AppStrings.Network.Follow.followers + AppStrings.Characters.dot)
        
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15, weight: .bold), range: (aString.string as NSString).range(of: followers))
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.label, range: (aString.string as NSString).range(of: followers))
        
        return aString
    }
    
    func followingText(valueFollowing: Int) -> NSAttributedString {
        let following = String(valueFollowing)
        
        let aString = NSMutableAttributedString(string: following + AppStrings.Network.Follow.following)
        
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15, weight: .bold), range: (aString.string as NSString).range(of: following))
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.label, range: (aString.string as NSString).range(of: following))
        
        return aString
    }
    
    func followingUserStats(valueFollowers: Int, valueFollowing: Int) -> NSAttributedString {
        let followers = followersText(valueFollowers: valueFollowers)
        let following = followingText(valueFollowing: valueFollowing)
        
        let left = NSMutableAttributedString(attributedString: followers)
        left.append(following)
        
        return left
    }
 
    init(user: User) {
        self.user = user
    }
}

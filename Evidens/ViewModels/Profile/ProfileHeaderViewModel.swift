//
//  ProfileHeaderViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/10/21.
//

import UIKit

struct ProfileHeaderViewModel {
    let user: User
    
    var firstName: String {
        return user.firstName!
    }
    
    var lastName: String {
        return user.lastName!
    }

    var profileImageUrl: URL? {
        return URL(string: user.profileImageUrl!)
    }
    
    var bannerImageUrl: URL? {
        return URL(string: user.bannerImageUrl!)
    }
    
    var userCategory: Int {
        // en funció de l'int tornar el text de categoría. mira rnotificacions que està fet així
        return user.category.rawValue
    }
    
    var profession: String {
        return user.profession!
    }
    
    var speciality: String {
        return user.speciality!
    }
    
    var pointsMessageText: String {
        return user.isCurrentUser ? "149 points" : "Message"
        // Implement user.isCurrentUser ? "FETCH POINTS" : "Message"
    }
    
    var messageButtonIsHidden: Bool {
        return user.isCurrentUser || !user.isFollowed ? true : false
    }
    
    //Change button text wether is, or not, current user
    var followButtonText: String {
        if user.isCurrentUser {
            return "Edit Profile"
        }
        
        return user.isFollowed ? "Following" : "Follow"
    }
    
    var customFollowButtonText: String {
        if user.isCurrentUser {
            return "Edit Profile"
        }
        
        return user.isFollowed ? "Following" : "    Follow    "
    }
    
    var followButtonBackgroundColor: UIColor {
        return user.isCurrentUser || user.isFollowed ? .systemBackground : .label
    }
    
    var followButtonTextColor: UIColor {
        return user.isCurrentUser || user.isFollowed ? .label : .systemBackground
    }
    
    var followButtonBorderColor: UIColor {
        return user.isCurrentUser || user.isFollowed ? .quaternarySystemFill : .label
    }
    
    var followButtonBorderWidth: CGFloat {
        return user.isFollowed || user.isCurrentUser ? 1 : 0
    }
    
    var editBannerButton: Bool {
        return user.isCurrentUser ? false : true
    }
    
    var followButtonImage: UIImage? {
        return user.isCurrentUser ? UIImage(named: "pencil") : UIImage(named: "")
    }
    

    var numberOfFollowers: Int {
        return user.stats.followers
    }
    
    var numberOfFollowing: Int {
        return user.stats.following
    }
    
    var followingFollowersText: NSAttributedString {
        return followingUserStats(valueFollowers: numberOfFollowers, valueFollowing: numberOfFollowing)
    }
    /*
    var numberOfPosts: String {
        return String(user.stats.posts)
    }
    */
    func followersString(valueFollowers: Int) -> NSAttributedString {
        let followers = String(valueFollowers)

        let aString = NSMutableAttributedString(string: followers + " followers      " + " · ")
        
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16, weight: .bold), range: (aString.string as NSString).range(of: followers))
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.label, range: (aString.string as NSString).range(of: followers))
        
        return aString
    }
    
    func followingString(valueFollowing: Int) -> NSAttributedString {
        let following = String(valueFollowing)
        
        let aString = NSMutableAttributedString(string: "      " + following + " following")
        
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16, weight: .bold), range: (aString.string as NSString).range(of: following))
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.label, range: (aString.string as NSString).range(of: following))
        
        return aString
    }
    
    func followingUserStats(valueFollowers: Int, valueFollowing: Int) -> NSAttributedString {
        let followers = followersString(valueFollowers: valueFollowers)
        let following = followingString(valueFollowing: valueFollowing)
        
        let left = NSMutableAttributedString(attributedString: followers)
        left.append(following)
        
        return left
    }
 
    init(user: User) {
        self.user = user
    }
}

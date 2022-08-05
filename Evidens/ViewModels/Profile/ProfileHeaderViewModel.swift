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
    
    //Change button text wether is, or not, current user
    var followButtonText: String {
        if user.isCurrentUser {
            return "Edit Profile"
        }
        
        return user.isFollowed ? "Following" : "Follow"
    }
    
    var followButtonBackgroundColor: UIColor {
        return user.isCurrentUser ? lightGrayColor : primaryColor
    }
    
    var followButtonTextColor: UIColor {
        return user.isCurrentUser ? .black : .white
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
        return followersString(valueFollowers: numberOfFollowers, valueFollowing: numberOfFollowing)
    }
    
    var numberOfPosts: String {
        return String(user.stats.posts)
    }
    
    func followersString(valueFollowers: Int, valueFollowing: Int) -> NSAttributedString {
        let aString = NSMutableAttributedString(string: "\(valueFollowers) followers     \(valueFollowing) following")
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16, weight: .regular), range: (aString.string as NSString).range(of: "\(valueFollowers) followers     \(valueFollowing) following"))
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: grayColor, range: (aString.string as NSString).range(of: "\(valueFollowers) followers     \(valueFollowing) following"))

        aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16, weight: .bold), range: (aString.string as NSString).range(of: "\(valueFollowers)"))
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: (aString.string as NSString).range(of: "\(valueFollowers)"))
        
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16, weight: .bold), range: (aString.string as NSString).range(of: "\(valueFollowing)"))
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: (aString.string as NSString).range(of: "\(valueFollowing)"))

        return aString
    }
 
    init(user: User) {
        self.user = user
    }
}

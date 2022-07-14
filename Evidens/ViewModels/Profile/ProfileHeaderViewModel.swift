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
    
    var userCategory: Int {
        // en funció de l'int tornar el text de categoría. mira rnotificacions que està fet així
        return user.category.rawValue
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
    
    var followButtonImage: UIImage? {
        return user.isCurrentUser ? UIImage(named: "pencil") : UIImage(named: "")
    }
    
    var followButtonTextColor: UIColor {
        return user.isCurrentUser ? blackColor : .white
    }
    
    var numberOfFollowers: NSAttributedString {
        return attributedStatText(value: user.stats.followers, label: "followers")
    }
    
    var numberOfFollowing: NSAttributedString {
        return attributedStatText(value: user.stats.following, label: "following")
    }
    
    var numberOfPosts: NSAttributedString {
        return attributedStatText(value: user.stats.posts, label: "posts")
    }
    
    func attributedStatText(value: Int, label: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "\(value) ", attributes: [.font: UIFont(name: "Raleway-SemiBold", size: 15)!])
        attributedText.append(NSAttributedString(string: label, attributes: [.font: UIFont(name: "Raleway-SemiBold", size: 15)!, .foregroundColor : UIColor.lightGray]))
        return attributedText
    }
    
    init(user: User) {
        self.user = user
    }
}

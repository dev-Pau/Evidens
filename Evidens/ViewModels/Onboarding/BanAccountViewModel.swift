//
//  BanAccountViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 11/10/23.
//

import UIKit

struct BanAccountViewModel {
    
    private let user: User
    
    init(user: User) {
        self.user = user
    }
    
    var banText: NSAttributedString {
        let banString = NSMutableAttributedString(string: AppStrings.Opening.banContent)
        banString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15, weight: .regular), range: NSRange(location: 0, length: banString.length))
        banString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.secondaryLabel, range: NSRange(location: 0, length: banString.length))

        let banRange = (banString.string as NSString).range(of: AppStrings.Opening.appeal)
        banString.addAttribute(NSAttributedString.Key.link, value: AppStrings.Opening.appeal, range: banRange)
        
        return banString
    }
}

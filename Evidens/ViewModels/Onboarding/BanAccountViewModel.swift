//
//  BanAccountViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 11/10/23.
//

import UIKit

/// The viewModel for a BanAccount.
struct BanAccountViewModel {
    
    private let user: User
    
    init(user: User) {
        self.user = user
    }
    
    var banText: NSAttributedString {
        let banString = NSMutableAttributedString(string: AppStrings.Opening.banContent)
        
        let font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        
        banString.addAttribute(NSAttributedString.Key.font, value: font, range: NSRange(location: 0, length: banString.length))
        banString.addAttribute(NSAttributedString.Key.foregroundColor, value: primaryGray, range: NSRange(location: 0, length: banString.length))

        let banRange = (banString.string as NSString).range(of: AppStrings.Opening.appeal)
        banString.addAttribute(NSAttributedString.Key.link, value: AppStrings.Opening.appeal, range: banRange)
        
        return banString
    }
}

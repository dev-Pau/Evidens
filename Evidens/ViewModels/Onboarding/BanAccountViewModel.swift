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
        banString.addAttribute(NSAttributedString.Key.font, value: UIFont.addFont(size: 15.0, scaleStyle: .largeTitle, weight: .regular), range: NSRange(location: 0, length: banString.length))
        banString.addAttribute(NSAttributedString.Key.foregroundColor, value: K.Colors.primaryGray, range: NSRange(location: 0, length: banString.length))
        return banString
    }
}

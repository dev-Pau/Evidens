//
//  ShareCaseViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 11/8/22.
//

import UIKit

protocol ShareContentViewModel {
    func updateForm()
}

protocol ShareViewModel {
    var caseIsValid: Bool { get }
    var buttonBackgroundColor: UIColor { get }
}

struct ShareCaseViewModel: ShareViewModel {

    var title: String?
    var description: String?
    var hashtags = [String]()
    
    private(set) var disciplines = [Discipline]()
    var images = [UIImage]()
    var privacy: CasePrivacy = .regular
    var specialities = [Speciality]()
    var items = [CaseItem]()

    var phase: CasePhase?
    var diagnosis: CaseRevision?
    
    var hasTitle: Bool {
        return title?.isEmpty == false
    }
    
    var hasDescription: Bool {
        return description?.isEmpty == false
    }
    
    var hasHashtags: Bool {
        return !hashtags.isEmpty
    }

    var hasImages: Bool {
        return !images.isEmpty
    }
    
    var caseIsValid: Bool {
        if hasTitle && hasDescription && !specialities.isEmpty && !items.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    var buttonBackgroundColor: UIColor {
        return caseIsValid ? primaryColor : primaryColor.withAlphaComponent(0.5)
    }
    
    var attributedPrivacyString: NSAttributedString {
        let aString = NSMutableAttributedString(string: "\(privacy.title). \(privacy.content).")
            aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15, weight: .medium), range: (aString.string as NSString).range(of: privacy.title))
            aString.addAttribute(NSAttributedString.Key.foregroundColor, value: primaryColor, range: (aString.string as NSString).range(of: privacy.title))
            return aString
        
    }
    
    var privacyImage: UIImage {
        return privacy.image.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel).scalePreservingAspectRatio(targetSize: CGSize(width: 23, height: 23))
    }
    
    var kind: CaseKind {
        return hasImages ? .image : .text
    }
    // MARK: - Operations
    
    mutating func removeImage(at index: Int) {
        images.remove(at: index)
    }
    
    mutating func set(disciplines: [Discipline]) {
        self.disciplines = disciplines
    }
}

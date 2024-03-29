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

/// The viewModel for a ShareCase.
struct ShareCaseViewModel: ShareViewModel {

    var title: String?
    var description: String?
    var hashtags = [String]()
    
    private(set) var disciplines = [Discipline]()
    var images = [CaseImage]()
    var privacy: CasePrivacy = .regular
    var bodyOrientation: BodyOrientation = .front
    var specialities = [Speciality]()
    var items = [CaseItem]()

    var phase: CasePhase?
    var diagnosis: CaseRevision?
    
    var bodyParts = [Body]()
    
    var maxBodyParts = 2
    var selectedBodyParts = 0
    
    let titleSize = 200
    let maxDescriptionCount = 700
    
    var hasTitle: Bool {
        return title?.trimmingCharacters(in: .whitespaces).isEmpty == false
    }
    
    var hasDescription: Bool {
        return description?.trimmingCharacters(in: .whitespaces).isEmpty == false
    }
    
    var hasHashtags: Bool {
        return !hashtags.isEmpty
    }
    
    var hasBody: Bool {
        return bodyParts.count > 0
    }

    var hasImages: Bool {
        return !images.isEmpty
    }
    
    var imagesRevealed: Bool {
        if images.isEmpty {
            return true
        } else {
            let revealed = images.filter({ !$0.isRevealed })
            if revealed.count > 0 {
                return false
            } else {
                return true
            }
        }
    }
    
    var caseIsValid: Bool {
        if hasTitle && hasDescription && !specialities.isEmpty && !items.isEmpty && imagesRevealed {
            return true
        } else {
            return false
        }
    }
    
    var buttonBackgroundColor: UIColor {
        return caseIsValid ? K.Colors.primaryColor : K.Colors.primaryColor.withAlphaComponent(0.5)
    }
    
    var attributedPrivacyString: NSAttributedString {
        
        let font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .medium)
        
        let aString = NSMutableAttributedString(string: "\(privacy.title). \(privacy.content).")
            aString.addAttribute(NSAttributedString.Key.font, value: font, range: (aString.string as NSString).range(of: privacy.title))
            aString.addAttribute(NSAttributedString.Key.foregroundColor, value: K.Colors.primaryColor, range: (aString.string as NSString).range(of: privacy.title))
            return aString
        
    }
    
    var privacyImage: UIImage {
        return privacy.image.withRenderingMode(.alwaysOriginal).withTintColor(K.Colors.primaryColor).scalePreservingAspectRatio(targetSize: CGSize(width: 23, height: 23))
    }
    
    var canSelectMoreBodyParts: Bool {
        return bodyParts.count < maxBodyParts
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

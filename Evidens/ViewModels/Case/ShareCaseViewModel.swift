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
    var numberOfSpecialities: Int?
    var numberOfDetails: Int?
    var stageSelected: Bool?
    var isFirstTime: Bool = true
    
    
    var images = [UIImage]()
    var privacy: Case.Privacy = Case.Privacy.visible
    var group: Group?
    var specialities = [String]()
    var professions = [String]()
    var details = [String]()
    var stage: Case.CaseStage?
    
    var diagnosis: String?
    
    
    var hasTitle: Bool {
        return title?.isEmpty == false
    }
    
    var hasDescription: Bool {
        return description?.isEmpty == false
    }
    
    var hasNumberOfSpecialities: Bool {
        guard let numberOfSpecialities = numberOfSpecialities else { return false }
        return numberOfSpecialities > 0 ? true : false
    }
    
    var hasNumberOfDetails: Bool {
        guard let numberOfDetails = numberOfDetails else { return false }
        return numberOfDetails > 0 ? true : false
    }
    
    var hasStageSelected: Bool {
        guard let stageSelected = stageSelected else { return false }
        return stageSelected == true ? true : false
    }
    
    var caseIsValid: Bool {
        if hasTitle && hasDescription && !specialities.isEmpty && !details.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    var showPrivacyMenu: Bool {
        return isFirstTime ? true : false
    }
    
    var buttonBackgroundColor: UIColor {
        return caseIsValid ? primaryColor : primaryColor.withAlphaComponent(0.5)
    }
    
    var attributedPrivacyString: NSAttributedString {
        if privacy == .group {
            let aString = NSMutableAttributedString(string: "Group. \(group!.name)")
            aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15, weight: .medium), range: (aString.string as NSString).range(of: "Group"))
            aString.addAttribute(NSAttributedString.Key.foregroundColor, value: primaryColor, range: (aString.string as NSString).range(of: "Group"))
            return aString
        } else {
            let aString = NSMutableAttributedString(string: "\(privacy.privacyTypeString). \(privacy.privacyTypeSubtitle).")
            aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15, weight: .medium), range: (aString.string as NSString).range(of: privacy.privacyTypeString))
            aString.addAttribute(NSAttributedString.Key.foregroundColor, value: primaryColor, range: (aString.string as NSString).range(of: privacy.privacyTypeString))
            return aString
        }
    }
    
    var privacyImage: UIImage {
        return privacy.privacyTypeImage.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel).scalePreservingAspectRatio(targetSize: CGSize(width: 23, height: 23))
    }

    // MARK: - Operations
    
    mutating func removeImage(at index: Int) {
        images.remove(at: index)
    }
}

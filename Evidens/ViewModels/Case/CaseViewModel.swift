//
//  CaseViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/7/22.
//

import UIKit

struct CaseViewModel {
    
    var clinicalCase: Case
    
    var caseTitle: String {
        return clinicalCase.title
    }
    
    var caseIsAnonymous: Bool {
        return clinicalCase.privacyOptions == .visible || clinicalCase.privacyOptions == .group ? false : true
    }
    
    var caseDescription: String {
        return clinicalCase.description
    }
    
    var caseSpecialities: [String] {
        return clinicalCase.specialities
    }
    
    var caseTypeDetails: [String] {
        return clinicalCase.details
    }
    
    var caseTags: [String] {
        return caseTypeDetails + caseSpecialities
    }
    
    var caseLikes: Int {
        return clinicalCase.likes
    }
    
    var caseComments: Int {
        return clinicalCase.numberOfComments
    }
    
    var caseViews: Int {
        return clinicalCase.numberOfViews
        
    }
    
    var caseStage: AttributedString {
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 11, weight: .semibold)
        
        return clinicalCase.stage.rawValue == 0 ? AttributedString("Solved", attributes: container) : AttributedString("Unsolved", attributes: container)
    }
    
    var caseStageString: String {
        return clinicalCase.stage.caseStageString
    }
    
    var caseInfoString: [String] {
        var caseInfoArray = [String]()
        caseInfoArray.append(caseStageString)
        
        if hasDiagnosis {
            caseInfoArray.append("Diagnosis")
        } else if hasUpdates {
            caseInfoArray.append("Revisions")
        }
        
        if clinicalCase.type == .image {
            caseInfoArray.append("Images")
        }
        
        caseInfoArray.append(timestampString!)
        
        return caseInfoArray
    }
    
    var caseSummaryInfoString: [String] {
        var caseInfoArray = [String]()
        caseInfoArray.append(caseStageString)
        
        if hasDiagnosis {
            caseInfoArray.append("Diagnosis")
        } else if hasUpdates {
            caseInfoArray.append("Revisions")
        }
        
        caseInfoArray.append(contentsOf: caseProfessions)
        
        return caseInfoArray
    }
    
    var caseImageStage: UIImage {
        return clinicalCase.stage.rawValue == 0 ? UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))! : UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
    }
    
    var privacyImage: UIImage {
        switch clinicalCase.privacyOptions {
        case .visible:
            return UIImage(systemName: "globe.europe.africa.fill")!.scalePreservingAspectRatio(targetSize: CGSize(width: 11.6, height: 11.6))
        case .nonVisible:
            return UIImage(systemName: "eyeglasses")!.scalePreservingAspectRatio(targetSize: CGSize(width: 11.6, height: 11.6))
        case .group:
            return UIImage(systemName: "person.2.fill")!.scalePreservingAspectRatio(targetSize: CGSize(width: 11.6, height: 11.6))
        }
    }
    
    var mainCaseProfession: Profession.Professions {
        guard let profession = clinicalCase.professions.first else { return .medicine }
        return Profession.Professions.init(rawValue: profession) ?? .medicine
    }
    
    var caseProfessions: [String] {
        return clinicalCase.professions
    }
    
    var caseBackgroundColor: UIColor {
        switch mainCaseProfession {
        case .medicine:
            return .systemTeal
        case .odontology:
            return .systemBlue
        case .pharmacy:
            return .systemPink
        case .physiotherapy:
            return .systemPurple
        case .nursing:
            return .systemCyan
        case .veterinary:
            return .systemIndigo
        case .psychology:
            return .systemMint
        case .podiatry:
            return .systemOrange
        case .nutrition:
            return .systemGreen
        case .optics:
            return .systemYellow
        case .biomedical:
            return .systemGray
        case .physical:
            return .systemBrown
        case .speech:
            return .systemRed
        }
    }
    
    var caseStageTextColor: UIColor {
        return clinicalCase.stage.rawValue == 0 ? .white : .systemBackground
    }
    
    var caseStageBackgroundColor: UIColor {
        return clinicalCase.stage.rawValue == 0 ? .systemGreen : .label
    }
    
    var hasDiagnosis: Bool {
        return clinicalCase.stage == .resolved && clinicalCase.revision == .diagnosis ? true : false
    }
    
    var hasUpdates: Bool {
        return clinicalCase.revision == .update
    }
    
    var diagnosisText: String {
        return clinicalCase.diagnosis
    }
    
    var timestampString: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: clinicalCase.timestamp.dateValue(), to: Date())
    }
    
    var caseType: Int {
        return clinicalCase.type.rawValue
    }
        
    var caseImagesCount: Int {
        return clinicalCase.caseImageUrl.count
    }
    
    var caseImages: [String] {
        if caseImagesCount > 0 {
            guard let first = clinicalCase.caseImageUrl.first, first != "" else {
                return [String]()
            }
            return clinicalCase.caseImageUrl
        }
        return [String]()
        
    }
    
    
    var isLikesHidden: Bool {
        if clinicalCase.likes == 0 {
            return true
        } else {
            return false
        }
    }
    
    var likesLabelText: String {
        if clinicalCase.likes > 0 {
            return "\(clinicalCase.likes)"
        } else {
            return ""
        }
    }
    
    var commentText: String {
        if caseComments > 1 { return "comments" }
        else { return "comment" }
    }
    
    var likesCommentsText: String {
        if caseLikes == 0 && caseComments == 0 {
            return ""
        } else if caseLikes != 0 && caseComments == 0 {
            return "\(caseLikes)"
        } else if caseLikes == 0 && caseComments != 0 {
            return "\(caseComments) \( commentText)"
        } else {
            return "\(caseLikes) • \(caseComments) \(commentText)"
        }
    }
    
    var likeButtonTintColor: UIColor {
        return clinicalCase.didLike ? pinkColor : .secondaryLabel
    }
    
    var likeButtonImage: UIImage? {
        let imageName = clinicalCase.didLike ? "heart.fill" : "heart"
        return UIImage(named: imageName)?.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25))
    }
    
    var commentsText: String {
        if clinicalCase.numberOfComments != 0 {
            return "\(caseComments)"
        } else {
            return ""
        }
    }
    
    var likesText: String {
        if clinicalCase.likes != 0 {
            return "\(caseLikes)"
        } else {
            return ""
        }
    }
    
    var likesButtonIsHidden: Bool {
        return caseLikes > 0 ? false : true
    }
    
    var bookMarkImage: UIImage? {
        let imageName = clinicalCase.didBookmark ? "bookmark.fill" : "bookmark"
        return UIImage(named: imageName)?.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25))
    }
}

//
//  CaseViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/7/22.
//

import UIKit

struct CaseViewModel {
    
    var clinicalCase: Case
    
    var title: String {
        return clinicalCase.title
    }
    
    var isAnonymous: Bool {
        return clinicalCase.privacy == .anonymous
    }
    
    var content: String {
        return clinicalCase.content
    }
    
    var caseSpecialities: [Speciality] {
        return clinicalCase.specialities
    }
    
    var caseTypeDetails: [CaseItem] {
        return clinicalCase.items
    }
    
    var caseTags: [String] {
        return caseTypeDetails.map { $0.title } + caseSpecialities.map { $0.name }
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
        switch clinicalCase.phase {
            
        case .solved: return AttributedString(AppStrings.Content.Case.Phase.solved, attributes: container)
        case .unsolved: return AttributedString(AppStrings.Content.Case.Phase.unsolved, attributes: container)
        }
    }
    
    var caseStageString: String {
        return clinicalCase.phase.title
    }
    
    var caseInfoString: [String] {
        var caseInfoArray = [String]()
        caseInfoArray.append(caseStageString)
        
        if hasDiagnosis {
            caseInfoArray.append("Diagnosis")
        } else if hasUpdates {
            caseInfoArray.append("Revisions")
        }
        
        if clinicalCase.kind == .image {
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
        
        caseInfoArray.append(contentsOf: caseProfessions.map { $0.name })
        
        return caseInfoArray
    }
    
    var caseImageStage: UIImage {
        switch clinicalCase.phase {
        case .solved: return UIImage(systemName: AppStrings.Icons.checkmark, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
        case .unsolved: return UIImage(systemName: AppStrings.Icons.magnifyingglass, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
        }
    }
    
    var privacyImage: UIImage {
        switch clinicalCase.privacy {
        case .regular: return UIImage(systemName: AppStrings.Icons.fillEuropeGlobe)!.scalePreservingAspectRatio(targetSize: CGSize(width: 11.6, height: 11.6))
        case .anonymous:
            return UIImage(systemName: AppStrings.Icons.eyeGlasses)!.scalePreservingAspectRatio(targetSize: CGSize(width: 11.6, height: 11.6))
        }
    }
    
    var mainCaseProfession: Discipline {
        return clinicalCase.disciplines.first ?? .medicine
    }
    
    var caseProfessions: [Discipline] {
        return clinicalCase.disciplines
    }
    
    var caseBackgroundColor: UIColor {
        return .systemMint
    }
    
    var caseStageTextColor: UIColor {
        switch clinicalCase.phase {
            
        case .solved:
            return .white
        case .unsolved:
            return .systemBackground
        }
    }
    
    var caseStageBackgroundColor: UIColor {
        switch clinicalCase.phase {
            
        case .solved:
            return .systemGreen
        case .unsolved:
            return .label
        }
    }
    
    var hasDiagnosis: Bool {
        return clinicalCase.phase == .solved && clinicalCase.revision == .diagnosis ? true : false
    }
    
    var hasUpdates: Bool {
        return clinicalCase.revision == .update
    }
    
    var timestampString: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: clinicalCase.timestamp.dateValue(), to: Date())
    }
    
    var caseType: CaseKind {
        return clinicalCase.kind
    }
        
    var caseImagesCount: Int {
        return clinicalCase.imageUrl.count
    }
    
    var caseImages: [String] {
        if caseImagesCount > 0 {
            guard let first = clinicalCase.imageUrl.first, first != "" else {
                return [String]()
            }
            return clinicalCase.imageUrl
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

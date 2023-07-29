//
//  RevisionKindViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/7/23.
//

import Firebase

struct RevisionKindViewModel {
    
    private var revision: CaseRevision
    
    init(revision: CaseRevision) {
        self.revision = revision
    }
    
    var title: String {
        return revision.title ?? String()
    }
    
    var content: String {
        return revision.content
    }
    
    var kind: String {
        switch revision.kind {
        case .clear: return ""
        case .update: return AppStrings.Content.Case.Share.revision
        case .diagnosis: return AppStrings.Content.Case.Share.diagnosis
        }
    }
    
    func elapsedTimestamp(from date: Date) -> String {
        let revisionDate = revision.timestamp.dateValue()
        guard date != revisionDate else { return "" }

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth, .year]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
            
        guard let elapsedString = formatter.string(from: date, to: revisionDate) else {
            return ""
        }
        
        return AppStrings.Characters.dot + elapsedString + " " + AppStrings.Miscellaneous.elapsed
    }

    var timestamp: String {
        let date = revision.timestamp.dateValue()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let formattedString = dateFormatter.string(from: date)
        
        return formattedString
    }
}

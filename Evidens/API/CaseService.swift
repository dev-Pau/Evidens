//
//  CaseService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/7/22.
//

import UIKit
import Firebase

struct CaseService {
    
    static func uploadCase(caseTitle: String, caseDescription: String, caseImageUrl: [String]?, specialities: [String], details: [String], stage: Case.CaseStage, diagnosis: String?, type: Case.CaseType, user: User, completion: @escaping(Error?) -> Void) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let data = ["title": caseTitle,
                    "description": caseDescription,
                    "specialities": specialities,
                    "details": details,
                    "likes": 0,
                    "stage": stage.caseStage,
                    "comments": 0,
                    "views": 0,
                    "diagnosis": diagnosis as Any,
                    "ownerUid": user.uid as Any,
                    "ownerCategory": user.category.rawValue,
                    "timestamp": Timestamp(date: Date()),
                    "type": type.rawValue,
                    "ownerFirstName": user.firstName as Any,
                    "ownerProfession": user.profession as Any,
                    "ownerSpeciality": user.speciality as Any,
                    "ownerLastName": user.lastName as Any,
                    "ownerImageUrl": user.profileImageUrl as Any,
                    "caseImageUrl": caseImageUrl as Any
        ]
        
        COLLECTION_CASES.addDocument(data: data, completion: completion)
    }
    
    static func fetchCases(completion: @escaping([Case]) -> Void) {
        COLLECTION_CASES.order(by: "timestamp", descending: true).getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            let cases = documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
            completion(cases)
        }
    }
}


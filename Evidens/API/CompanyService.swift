//
//  CompanyService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/2/23.
//

import Foundation
import Firebase

struct CompanyService {
    
    static func uploadCompany(company: Company, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let companyRef = COLLECTION_COMPANIES.document(company.id)
        
        let data = ["id": company.id,
                    "ownerUid": uid,
                    "location": company.location,
                    "name": company.name,
                    "description": company.description,
                    "companyImageUrl": company.companyImageUrl as Any,
                    "industry": company.industry,
                    "specialities": company.specialities,
                    "timestamp": Timestamp(date: Date())] as [String : Any]
        
        companyRef.setData(data, completion: completion)
        
        DatabaseManager.shared.uploadCompany(companyId: company.id) { _ in }
    }
    
    static func fetchCompaniesDocuments(completion: @escaping(QuerySnapshot) -> Void) {
        let firstCompaniesToFetch = COLLECTION_COMPANIES.limit(to: 20)
        firstCompaniesToFetch.getDocuments { snapshot, error in
            guard let snapshot = snapshot else { return }
            guard snapshot.documents.last != nil else { return }
            completion(snapshot)
        }
    }
    
    static func searchCompanyWithText(text: String, completion: @escaping([Company]) -> Void) {
        var companies = [Company]()
        COLLECTION_COMPANIES.order(by: "name").whereField("name", isGreaterThanOrEqualTo: text.capitalized).whereField("name",
                                                                                                                       isLessThanOrEqualTo: text.capitalized+"\u{f8ff}").limit(to: 20).getDocuments { snapshot, error in
            
            guard let snapshot = snapshot else {
                completion(companies)
                return
            }
            
            companies = snapshot.documents.map({ Company(dictionary: $0.data()) })
            completion(companies)
        }
    }
}

//
//  Job.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/2/23.
//

import UIKit
import Firebase

struct Job {
    
    let ownerUid: String
    
    let jobId: String
    let title: String
    let description: String
    let workplaceType: String
    let jobType: String
    let activePeriod: String
    let timestamp: Timestamp
    let professions: Profession
    
    let companyId: String
    
    init(jobId: String, dictionary: [String: Any]) {
        self.jobId = jobId
        self.ownerUid = dictionary["ownerUid"] as? String ?? ""
        self.title = dictionary["title"] as? String ?? ""
        self.description = dictionary["description"] as? String ?? ""
        self.workplaceType = dictionary["workplaceType"] as? String ?? ""
        self.jobType = dictionary["jobType"] as? String ?? ""
        self.activePeriod = dictionary["activePeriod"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.professions = dictionary["professions"] as? Profession ?? Profession(profession: "")
        self.companyId = dictionary["companyId"] as? String ?? ""
    }
}

extension Job {
    enum WorksplaceType: String, CaseIterable {
        case onSite = "On-site"
        case hybrid = "Hybrid"
        case remote = "Remote"
        
        var JobTypeDescription: String {
            switch self {
            case .onSite:
                return "Employees come to work in person."
            case .hybrid:
                return "Employees work on-site and off-site."
            case .remote:
                return "Employees work off-site."
            }
        }
    }
    
    enum JobType: String, CaseIterable {
        case full = "Full-time"
        case part = "Part-Time"
        case contract = "Contract"
        case temporary = "Temporary"
        case other = "Other"
        case volunteer = "Volunteer"
        case internship = "Internship"
    }
    
    enum JobSections: String, CaseIterable {
        case title = "Title"
        case description = "Description"
        case role = "Role"
        case workplace = "Workplace"
        case location = "Location"
        case type = "Type"
        case professions = "Profession"
    }
    
    /*
    enum JobTitle: String, CaseIterable {

    }
     */
}

struct Company {
    let id: String
    let ownerUid: String
    let location: String
    let name: String
    let description: String
    let companyImageUrl: String?
    let industry: String
    let specialities: [Speciality]
    
    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.ownerUid = dictionary["ownerUid"] as? String ?? ""
        self.location = dictionary["location"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.description = dictionary["description"] as? String ?? ""
        self.companyImageUrl = dictionary["companyImageUrl"] as? String ?? ""
        self.industry = dictionary["industry"] as? String ?? ""
        self.specialities = dictionary["specialities"] as? [Speciality] ?? [Speciality(name: "")]
    }
}

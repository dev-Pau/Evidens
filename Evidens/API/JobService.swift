//
//  JobService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/2/23.
//

import UIKit
import Firebase

struct JobService {
    
    static func uploadJob(job: Job, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }

        let jobRef = COLLECTION_JOBS.document(job.jobId)

        let data = ["jobId": job.jobId,
                    "ownerUid": uid,
                    "title": job.title,
                    "description": job.description,
                    "workplaceType": job.workplaceType,
                    "jobtype": job.jobType,
                    "profession": job.professions.profession,
                    "companyId": job.companyId,
                    "timestamp": Timestamp(date: Date())] as [String : Any]
        
        jobRef.setData(data, completion: completion)
        
        DatabaseManager.shared.uploadJob(jobId: job.jobId) { _ in }
    }
    
    static func fetchJobs() {
        
    }
}

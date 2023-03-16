//
//  JobService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/2/23.
//

import UIKit
import Firebase
import FirebaseFirestore

struct JobService {
    
    static func uploadJob(job: Job, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }

        let jobRef = COLLECTION_JOBS.document(job.jobId)

        let data = ["jobId": job.jobId,
                    "ownerUid": uid,
                    "title": job.title,
                    "location": job.location,
                    "description": job.description,
                    "workplaceType": job.workplaceType,
                    "stage": Job.JobStage.review.rawValue,
                    "jobType": job.jobType,
                    "profession": job.profession,
                    "companyId": job.companyId,
                    "timestamp": Timestamp(date: Date())] as [String : Any]
        
        jobRef.setData(data, completion: completion)
        
        DatabaseManager.shared.uploadJob(jobId: job.jobId) { _ in }
    }
    
    static func updateGroup(from job: Job, to newJob: Job, completion: @escaping(Job) -> Void) {
        // Check what group values have changed
        var updatedJobData = [String: Any]()
        /*


         jobToUpload.profession = profession
         jobToUpload.companyId = companyId
         */

        
        let title = (job.title == newJob.title) ? nil : newJob.title
        let description = (job.description == newJob.description) ? nil : newJob.description
        let location = (job.location == newJob.location) ? nil : newJob.location
        let workplaceType = (job.workplaceType == newJob.workplaceType) ? nil : newJob.workplaceType
        let type = (job.jobType == newJob.jobType) ? nil : newJob.jobType
        let profession = (job.profession == newJob.profession) ? nil : newJob.profession
        

        if let title = title { updatedJobData["title"] = title }
        if let description = description { updatedJobData["description"] = description }
        if let location = location { updatedJobData["location"] = location }
        if let workplaceType = workplaceType { updatedJobData["workplaceType"] = workplaceType }
        if let type = type { updatedJobData["type"] = type }
        if let profession = profession { updatedJobData["profession"] = profession }
        
        if updatedJobData.isEmpty {
            completion(job)
            return
        }
        
        COLLECTION_JOBS.document(job.jobId).updateData(updatedJobData) { error in
            if error != nil { return }
            COLLECTION_JOBS.document(job.jobId).getDocument { snapshot, error in
                guard let dictionary = snapshot?.data() else { return }
                let job = Job(jobId: job.jobId, dictionary: dictionary)
                completion(job)
            }
        }
    }
    
    
    static func fetchJobs(lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
        if lastSnapshot == nil {
            let firstJobsToFetch = COLLECTION_JOBS.limit(to: 10)
            firstJobsToFetch.getDocuments { snapshot, error in
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(snapshot!)
                    return
                }
                guard snapshot.documents.last != nil else {
                    completion(snapshot)
                    return
                }
                completion(snapshot)
            }
        } else {
            let nextJobsToFetch = COLLECTION_JOBS.start(afterDocument: lastSnapshot!).limit(to: 10)
            nextJobsToFetch.getDocuments { snapshot, error in
                guard let snapshot = snapshot else { return }
                guard snapshot.documents.last != nil else { return }
                completion(snapshot)
            }
        }
    }
    
    static func fetchJob(withJobId id: String, completion: @escaping(Job) -> Void) {
        COLLECTION_JOBS.document(id).getDocument { snapshot, error in
            guard let snapshot = snapshot else { return }
            guard let data = snapshot.data() else { return }
            let job = Job(jobId: snapshot.documentID, dictionary: data)
            completion(job)
        }
    }
    
    
    static func fetchJobs(withJobIds ids: [String], completion: @escaping([Job]) -> Void) {
        var jobs = [Job]()
        ids.forEach { id in
            fetchJob(withJobId: id) { job in
                jobs.append(job)
                if jobs.count == ids.count {
                    completion(jobs)
                }
            }
        }
    }
    
    static func fetchTopJobsForTopic(topic: String, completion: @escaping([Job]) -> Void) {
        let query = COLLECTION_JOBS.whereField("profession", isEqualTo: topic).limit(to: 3)
        query.getDocuments { (snapshot, error) in
            guard let snapshot = snapshot, !snapshot.isEmpty else {
                completion([])
                return
            }
            
            var jobs = snapshot.documents.map( { Job(jobId: $0.documentID, dictionary: $0.data()) })
            completion(jobs)
            
        }
    }
    
    static func bookmarkJob(job: Job, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }

        COLLECTION_JOBS.document(job.jobId).collection("job-bookmarks").document(uid).setData([:]) { _ in
            //Update user bookmarks collection to track bookmarks for a particular user
            COLLECTION_USERS.document(uid).collection("user-job-bookmarks").document(job.jobId).setData(["timestamp": Timestamp(date: Date())], completion: completion)
        }
    }
    
    static func unbookmarkJob(job: Job, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }

        COLLECTION_JOBS.document(job.jobId).collection("job-bookmarks").document(uid).delete() { _ in
            //Update user bookmarks collection to track bookmarks for a particular user
            COLLECTION_USERS.document(uid).collection("user-job-bookmarks").document(job.jobId).delete(completion: completion)
        }
    }
    
    static func checkIfUserBookmarkedJob(job: Job, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        COLLECTION_USERS.document(uid).collection("user-job-bookmarks").document(job.jobId).getDocument { (snapshot, _) in
            //If the snapshot (document) exists, means current user did like the post
            guard let didBookmark = snapshot?.exists else { return }
            completion(didBookmark)
        }
    }
    
    /*
     
     */
     static func fetchBookmarkedJobsDocuments(lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot?) -> Void) {
         guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }

         if lastSnapshot == nil {
             let firstGroupToFetch = COLLECTION_USERS.document(uid).collection("user-job-bookmarks").order(by: "timestamp", descending: true).limit(to: 10)
             firstGroupToFetch.getDocuments { snapshot, error in
                 guard let snapshot = snapshot else {
                     completion(snapshot)
                     return
                 }
                 guard snapshot.documents.last != nil else {
                     completion(snapshot)
                     return
                     
                 }
                 completion(snapshot)
             }
         } else {
             let nextGroupToFetch = COLLECTION_USERS.document(uid).collection("user-job-bookmarks").order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 10)
             nextGroupToFetch.getDocuments { snapshot, error in
                 guard let snapshot = snapshot else { return }
                 guard snapshot.documents.last != nil else { return }
                 completion(snapshot)
             }
         }
     }
     
     static func fetchBookmarkedJobs(snapshot: QuerySnapshot, completion: @escaping([Job]) -> Void) {
         var jobs = [Job]()
         snapshot.documents.forEach({ document in
                 fetchJob(withJobId: document.documentID) { job in
                     jobs.append(job)
                     jobs.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                     completion(jobs)
             }
         })
     }
}

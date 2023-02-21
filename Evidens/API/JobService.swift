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
                    "location": job.location,
                    "description": job.description,
                    "workplaceType": job.workplaceType,
                    "jobType": job.jobType,
                    "profession": job.profession,
                    "companyId": job.companyId,
                    "timestamp": Timestamp(date: Date())] as [String : Any]
        
        jobRef.setData(data, completion: completion)
        
        DatabaseManager.shared.uploadJob(jobId: job.jobId) { _ in }
    }
    
    static func fetchJobs(lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
        if lastSnapshot == nil {
            let firstJobsToFetch = COLLECTION_JOBS.limit(to: 10)
            firstJobsToFetch.getDocuments { snapshot, error in
                guard let snapshot = snapshot else { return }
                guard snapshot.documents.last != nil else { return }
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
            var job = Job(jobId: snapshot.documentID, dictionary: data)
            completion(job)
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
     static func fetchBookmarkedJobsDocuments(lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
         guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
         
         if lastSnapshot == nil {
             let firstGroupToFetch = COLLECTION_USERS.document(uid).collection("user-job-bookmarks").order(by: "timestamp", descending: true).limit(to: 10)
             firstGroupToFetch.addSnapshotListener { snapshot, error in
                 guard let snapshot = snapshot else { return }
                 guard snapshot.documents.last != nil else { return }
                 completion(snapshot)
             }
         } else {
             let nextGroupToFetch = COLLECTION_USERS.document(uid).collection("user-job-bookmarks").order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 10)
             nextGroupToFetch.addSnapshotListener { snapshot, error in
                 guard let snapshot = snapshot else { return }
                 guard snapshot.documents.last != nil else { return }
                 completion(snapshot)
             }
         }
     }
     
     static func fetchBookmarkedJobs(snapshot: QuerySnapshot, completion: @escaping([Job]) -> Void) {
         var jobs = [Job]()
         snapshot.documents.forEach({ document in
                 fetchJob(withJobId: document.documentID) { post in
                     jobs.append(post)
                     jobs.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                     completion(jobs)
             }
         })
     }
}

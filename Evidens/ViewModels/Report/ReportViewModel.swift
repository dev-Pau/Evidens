//
//  ReportViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 29/9/23.
//

import Foundation

struct ReportViewModel {
    
    private(set) var report: Report
    
    init(report: Report) {
        self.report = report
    }
    
    var contentId: String {
        return report.contentId
    }
    
    var contentUid: String {
        return report.contentUid
    }
    
    var uid: String {
        return report.uid
    }
    
    var target: ReportTarget? {
        return report.target
    }
    
    var topic: ReportTopic? {
        return report.topic
    }
    
    var source: ReportSource {
        return report.source
    }
    
    var content: String? {
        return report.content
    }
    
    func addReport(completion: @escaping(DatabaseError?) -> Void) {
        DatabaseManager.shared.report(viewModel: self) { error in
            if let error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    mutating func edit(content: String?) {
        report.content = content
    }
    
    mutating func edit(target: ReportTarget) {
        report.target = target
    }
    
    mutating func edit(topic: ReportTopic) {
        report.topic = topic
    }
}

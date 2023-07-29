//
//  Report.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/4/23.
//

import UIKit

/// The model for a Report.
struct Report {
    
    var contentId: String
    var contentUid: String
    var uid: String
    var source: ReportSource
    
    var content: String?
    var target: ReportTarget?
    var topic: ReportTopic?

    
    /// Initializes a new instance of a Report using a dictionary.
    ///
    /// - Parameters:
    ///   - dictionary: A dictionary containing the Report data.
    ///     - Key: The key representing the specific data field.
    ///     - Value: The value associated with the key.
    init(dictionary: [String: Any]) {
        self.contentId = dictionary["contentId"] as? String ?? ""
        self.contentUid = dictionary["contentUid"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.source = ReportSource(rawValue: dictionary["source"] as? Int ?? 0) ?? .post
        
        self.target = ReportTarget(rawValue: dictionary["target"] as? Int ?? ReportTarget.myself.rawValue) ?? .myself
        self.topic = ReportTopic(rawValue: dictionary["topic"] as? Int ?? ReportTopic.identity.rawValue ) ?? .identity

        if let content = dictionary["content"] as? String {
            self.content = content
        }
    }
    
    /// Initializes a new instance of a Report with required properties.
    ///
    /// - Parameters:
    ///   - contentId: The unique identifier of the content being reported.
    ///   - contentUid: The unique identifier of the user who created the content being reported.
    ///   - uid: The unique identifier of the user reporting the content.
    ///   - source: The source of the report, indicating the type of content being reported (e.g., post, comment, etc.).
    init(contentId: String, contentUid: String, uid: String, source: ReportSource) {
        self.contentId = contentId
        self.contentUid = contentUid
        self.uid = uid
        self.source = source
    }
}

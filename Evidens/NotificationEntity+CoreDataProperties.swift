//
//  NotificationEntity+CoreDataProperties.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 30/8/23.
//


import Foundation
import CoreData


extension NotificationEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NotificationEntity> {
        return NSFetchRequest<NotificationEntity>(entityName: "NotificationEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var uid: String?
    @NSManaged public var kind: Int16

    @NSManaged public var timestamp: Date?
    
    @NSManaged public var image: String?
    @NSManaged public var name: String?
    
    @NSManaged public var contentId: String?
    @NSManaged public var content: String?
    
    @NSManaged public var commentId: String?

    @NSManaged public var isFollowed: Bool
    @NSManaged public var isRead: Bool
    
    @NSManaged public var likes: Int16
    
    @NSManaged public var path: [String]?
    
    var wrappedId: String {
        id ?? UUID().uuidString
    }
    
    var wrappedUid: String {
        uid ?? ""
    }
    
    var wrappedTimestamp: Date {
        timestamp ?? Date()
    }
    



    


    /*
     
     let id: String
     let uid: String
     let kind: NotificationKind
     let timestamp: Date

     
     private(set) var image: String?
     var name: String?

     var isFollowed: Bool?
     var content: String?

     var isRead: Bool = false
     
     */
}


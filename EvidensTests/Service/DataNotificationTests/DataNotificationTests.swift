//
//  NotificationTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 17/9/23.
//

import XCTest
import CoreData
@testable import Evidens

final class NotificationTests: XCTestCase {

    var sut: DataService!
    
    override func setUpWithError() throws {
        sut = DataService.shared
        sut.mockManagedObjectContext = mockPersistantContainer.viewContext
    }

    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testDataService_WhenSavingLikePostNotification_NotificationIsSaved() {

        let data = ["id": "notificationId",
                    "uid": "userUid",
                    "kind": NotificationKind.likePost.rawValue,
                    "timestamp": Date.now,
                    "contentId": "contentId",
                    "path": ["path1", "path2"]
        ] as [String : Any]
        
        let notification = Notification(dictionary: data)
        
        sut.save(notification: notification)
        let notifications = sut.getNotifications()

        XCTAssertEqual(notifications.count, 1)
    }
    
    
    func testDataService_WhenSavingLikePostNotification_ValuesAreAssignedCorrectly() {

        var data = ["id": "notificationId",
                    "uid": "userUid",
                    "kind": NotificationKind.likePost.rawValue,
                    "timestamp": Date.now,
                    "contentId": "contentId",
                    "content": "Content of the notification",
        ] as [String : Any]
        
        let notification = Notification(dictionary: data)
        
        sut.save(notification: notification)
        let notifications = sut.getNotifications()
        
        XCTAssertEqual(notifications.first?.id, "notificationId")
        XCTAssertEqual(notifications.first?.uid, "userUid")
        XCTAssertEqual(notifications.first?.kind.rawValue, NotificationKind.likePost.rawValue)
    }

    lazy var mockPersistantContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in
            // Check if the data store is in memory
            precondition( description.type == NSInMemoryStoreType )
            
            // Check if creating container wrong
            if let error = error {
                fatalError("Create an in-mem coordinator failed \(error)")
            }
        }
        return container
    }()

}

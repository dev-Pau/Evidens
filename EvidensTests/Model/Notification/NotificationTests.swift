//
//  NotificationTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 17/9/23.
//

import XCTest
import CoreData
import Firebase
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
    
    func testSavingLikePostNotification() {

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
    
    func testEditLikePostNotification() {
        let date = Timestamp(date: Date.now)
        
        let data = ["id": "notificationId",
                    "uid": "userUid",
                    "kind": NotificationKind.likePost.rawValue,
                    "timestamp": date,
                    "contentId": "contentId"
        ] as [String : Any]
        
        
        var notification = Notification(dictionary: data)
        
        notification.set(content: "Content of the notification")
        notification.set(likes: 3)
        
        sut.save(notification: notification)

        let notifications = sut.getNotifications()
        
        XCTAssertEqual(notifications.first?.id, "notificationId")
        XCTAssertEqual(notifications.first?.uid, "userUid")
        XCTAssertEqual(notifications.first?.contentId, "contentId")
        XCTAssertEqual(notifications.first?.timestamp, date.dateValue())
        XCTAssertEqual(notifications.first?.content, "Content of the notification")
        XCTAssertEqual(notifications.first?.likes, 3)
        XCTAssertEqual(notifications.first?.kind.rawValue, NotificationKind.likePost.rawValue)
    }
    
    
    func testCaseLikeSaveNotification() {

        let data = ["id": "notificationId",
                    "uid": "userUid",
                    "kind": Int(NotificationKind.likeCase.rawValue),
                    "timestamp": Date.now,
                    "contentId": "contentId",
                    "path": ["path1", "path2"]
        ] as [String : Any]
        
        let notification = Notification(dictionary: data)
        
        sut.save(notification: notification)
        let notifications = sut.getNotifications()

        XCTAssertEqual(notifications.count, 1)
    }
    
    func testEditLikeCaseNotification() {
        let date = Timestamp(date: Date.now)
        
        let data = ["id": "notificationId",
                    "uid": "userUid",
                    "kind": Int(NotificationKind.likeCase.rawValue),
                    "timestamp": date,
                    "contentId": "contentId",
        ] as [String : Any]
        
        var notification = Notification(dictionary: data)
        
        notification.set(likes: 1)
        notification.set(content: "Content of the notification")
        
        sut.save(notification: notification)
        let notifications = sut.getNotifications()

        XCTAssertEqual(notifications.first?.id, "notificationId")
        XCTAssertEqual(notifications.first?.uid, "userUid")
        XCTAssertEqual(notifications.first?.kind.rawValue, NotificationKind.likeCase.rawValue)
        XCTAssertEqual(notifications.first?.timestamp, date.dateValue())
        XCTAssertEqual(notifications.first?.contentId, "contentId")
        XCTAssertEqual(notifications.first?.likes, 1)
        XCTAssertEqual(notifications.first?.content, "Content of the notification")
    }
    
    func testSaveConnectionNotification() {
        let date = Timestamp(date: Date.now)
        
        let data = ["id": "notificationId",
                    "uid": "userUid",
                    "kind": Int(NotificationKind.connectionRequest.rawValue),
                    "timestamp": date,
        ] as [String : Any]
        
        let notification = Notification(dictionary: data)
        
        sut.save(notification: notification)
        let notifications = sut.getNotifications()

        XCTAssertEqual(notifications.count, 1)
    }
    
    func testEditConnectionNotification() {
        let date = Timestamp(date: Date.now)
        
        let data = ["id": "notificationId",
                    "uid": "userUid",
                    "kind": Int(NotificationKind.connectionRequest.rawValue),
                    "timestamp": date
        ] as [String : Any]
        
        var notification = Notification(dictionary: data)
        
        notification.set(isFollowed: true)
        
        sut.save(notification: notification)
        let notifications = sut.getNotifications()

        XCTAssertEqual(notifications.first?.id, "notificationId")
        XCTAssertEqual(notifications.first?.uid, "userUid")
        XCTAssertEqual(notifications.first?.isFollowed, true)
        XCTAssertEqual(notifications.first?.timestamp, date.dateValue())
        XCTAssertEqual(notifications.first?.kind.rawValue, NotificationKind.connectionRequest.rawValue)
    }
    
    
    func testSaveReplyPostNotification() {

        let data = ["id": "notificationId",
                    "uid": "userUid",
                    "kind": Int(NotificationKind.replyPost.rawValue),
                    "contentId": "contentId",
                    "path": ["path1", "path2"]
        ] as [String : Any]
        
        let notification = Notification(dictionary: data)
        
        sut.save(notification: notification)
        let notifications = sut.getNotifications()

        XCTAssertEqual(notifications.count, 1)
    }
    
    func testEditReplyPostNotification() {
        let date = Timestamp(date: Date.now)
        
        let data = ["id": "notificationId",
                    "uid": "userUid",
                    "kind": Int(NotificationKind.replyPost.rawValue),
                    "timestamp": date,
                    "contentId": "contentId",
                    "path": ["path1", "path2"]
        ] as [String : Any]
        
        var notification = Notification(dictionary: data)
        notification.set(content: "This is the reply")
        
        sut.save(notification: notification)
        let notifications = sut.getNotifications()

        XCTAssertEqual(notifications.first?.id, "notificationId")
        XCTAssertEqual(notifications.first?.uid, "userUid")
        XCTAssertEqual(notifications.first?.timestamp, date.dateValue())
        XCTAssertEqual(notifications.first?.contentId, "contentId")
        XCTAssertEqual(notifications.first?.kind.rawValue, NotificationKind.replyPost.rawValue)
        XCTAssertEqual(notifications.first?.content, "This is the reply")
        XCTAssertEqual(notifications.first?.path, ["path1", "path2"])
    }
    
    func testSaveReplyCaseNotification() {

        let data = ["id": "notificationId",
                    "uid": "userUid",
                    "kind": Int(NotificationKind.replyCase.rawValue),
                    "contentId": "contentId",
                    "path": ["path1", "path2"]
        ] as [String : Any]
        
        let notification = Notification(dictionary: data)
        
        sut.save(notification: notification)
        let notifications = sut.getNotifications()

        XCTAssertEqual(notifications.count, 1)
    }
    
    func testEditReplyCaseNotification() {
        let date = Timestamp(date: Date.now)
        
        let data = ["id": "notificationId",
                    "uid": "userUid",
                    "kind": Int(NotificationKind.replyCase.rawValue),
                    "timestamp": date,
                    "contentId": "contentId",
                    "path": ["path1", "path2"]
        ] as [String : Any]
        
        var notification = Notification(dictionary: data)
        notification.set(content: "This is the reply")
        
        sut.save(notification: notification)
        let notifications = sut.getNotifications()

        XCTAssertEqual(notifications.first?.id, "notificationId")
        XCTAssertEqual(notifications.first?.uid, "userUid")
        XCTAssertEqual(notifications.first?.timestamp, date.dateValue())
        XCTAssertEqual(notifications.first?.contentId, "contentId")
        XCTAssertEqual(notifications.first?.kind.rawValue, NotificationKind.replyCase.rawValue)
        XCTAssertEqual(notifications.first?.content, "This is the reply")
        XCTAssertEqual(notifications.first?.path, ["path1", "path2"])
    }
    
    func testSaveReplyPostCommentNotification() {

        let data = ["id": "notificationId",
                    "uid": "userUid",
                    "kind": Int(NotificationKind.replyPostComment.rawValue),
                    "contentId": "contentId",
                    "path": ["path1", "path2"]
        ] as [String : Any]
        
        let notification = Notification(dictionary: data)
        
        sut.save(notification: notification)
        let notifications = sut.getNotifications()

        XCTAssertEqual(notifications.count, 1)
    }
    
    func tesEditReplyPostCommentNotification() {
        let date = Timestamp(date: Date.now)
        
        let data = ["id": "notificationId",
                    "uid": "userUid",
                    "kind": Int(NotificationKind.replyPostComment.rawValue),
                    "timestamp": date,
                    "contentId": "contentId",
                    "path": ["path1", "path2"]
        ] as [String : Any]
        
        var notification = Notification(dictionary: data)
        notification.set(content: "This is the post reply")
        
        sut.save(notification: notification)
        let notifications = sut.getNotifications()

        XCTAssertEqual(notifications.first?.id, "notificationId")
        XCTAssertEqual(notifications.first?.uid, "userUid")
        XCTAssertEqual(notifications.first?.timestamp, date.dateValue())
        XCTAssertEqual(notifications.first?.contentId, "contentId")
        XCTAssertEqual(notifications.first?.kind.rawValue, NotificationKind.replyPostComment.rawValue)
        XCTAssertEqual(notifications.first?.content, "This is the post reply")
        XCTAssertEqual(notifications.first?.path, ["path1", "path2"])
    }
    
    func testSaveReplyCaseCommentNotification() {

        let data = ["id": "notificationId",
                    "uid": "userUid",
                    "kind": Int(NotificationKind.replyCaseComment.rawValue),
                    "contentId": "contentId",
                    "path": ["path1", "path2"]
        ] as [String : Any]
        
        let notification = Notification(dictionary: data)
        
        sut.save(notification: notification)
        let notifications = sut.getNotifications()

        XCTAssertEqual(notifications.count, 1)
    }
    
    func testEditReplyPostCommentNotification() {
        let date = Timestamp(date: Date.now)
        
        let data = ["id": "notificationId",
                    "uid": "userUid",
                    "kind": Int(NotificationKind.replyCaseComment.rawValue),
                    "timestamp": date,
                    "contentId": "contentId",
                    "path": ["path1", "path2"]
        ] as [String : Any]
        
        var notification = Notification(dictionary: data)
        notification.set(content: "This is the case reply")
        
        sut.save(notification: notification)
        let notifications = sut.getNotifications()

        XCTAssertEqual(notifications.first?.id, "notificationId")
        XCTAssertEqual(notifications.first?.uid, "userUid")
        XCTAssertEqual(notifications.first?.timestamp, date.dateValue())
        XCTAssertEqual(notifications.first?.contentId, "contentId")
        XCTAssertEqual(notifications.first?.kind.rawValue, NotificationKind.replyCaseComment.rawValue)
        XCTAssertEqual(notifications.first?.content, "This is the case reply")
        XCTAssertEqual(notifications.first?.path, ["path1", "path2"])
    }
    
    func testSaveLikePostReplyNotification() {

        let data = ["id": "notificationId",
                    "uid": "userUid",
                    "kind": Int(NotificationKind.likePostReply.rawValue),
                    "contentId": "contentId",
                    "path": ["path1", "path2"]
        ] as [String : Any]
        
        let notification = Notification(dictionary: data)
        
        sut.save(notification: notification)
        let notifications = sut.getNotifications()

        XCTAssertEqual(notifications.count, 1)
    }
    
    func testEditLikePostReplyNotification() {
        let date = Timestamp(date: Date.now)
        
        let data = ["id": "notificationId",
                    "uid": "userUid",
                    "kind": Int(NotificationKind.likePostReply.rawValue),
                    "timestamp": date,
                    "contentId": "contentId",
                    "path": ["path1", "path2"]
        ] as [String : Any]
        
        var notification = Notification(dictionary: data)
        notification.set(likes: 5)
        
        sut.save(notification: notification)
        let notifications = sut.getNotifications()

        XCTAssertEqual(notifications.first?.id, "notificationId")
        XCTAssertEqual(notifications.first?.uid, "userUid")
        XCTAssertEqual(notifications.first?.timestamp, date.dateValue())
        XCTAssertEqual(notifications.first?.contentId, "contentId")
        XCTAssertEqual(notifications.first?.kind.rawValue, NotificationKind.likePostReply.rawValue)
        XCTAssertEqual(notifications.first?.likes, 5)
        XCTAssertEqual(notifications.first?.path, ["path1", "path2"])
    }
    
    func testSaveLikeCaseReplyNotification() {

        let data = ["id": "notificationId",
                    "uid": "userUid",
                    "kind": Int(NotificationKind.likeCaseReply.rawValue),
                    "contentId": "contentId",
                    "path": ["path1", "path2"]
        ] as [String : Any]
        
        let notification = Notification(dictionary: data)
        
        sut.save(notification: notification)
        let notifications = sut.getNotifications()

        XCTAssertEqual(notifications.count, 1)
    }
    
    func testEditLikeCaseReplyNotification() {
        let date = Timestamp(date: Date.now)
        
        let data = ["id": "notificationId",
                    "uid": "userUid",
                    "kind": Int(NotificationKind.likeCaseReply.rawValue),
                    "timestamp": date,
                    "contentId": "contentId",
                    "path": ["path1", "path2"]
        ] as [String : Any]
        
        var notification = Notification(dictionary: data)
        notification.set(likes: 12)
        
        sut.save(notification: notification)
        let notifications = sut.getNotifications()

        XCTAssertEqual(notifications.first?.id, "notificationId")
        XCTAssertEqual(notifications.first?.uid, "userUid")
        XCTAssertEqual(notifications.first?.timestamp, date.dateValue())
        XCTAssertEqual(notifications.first?.contentId, "contentId")
        XCTAssertEqual(notifications.first?.kind.rawValue, NotificationKind.likeCaseReply.rawValue)
        XCTAssertEqual(notifications.first?.likes, 12)
        XCTAssertEqual(notifications.first?.path, ["path1", "path2"])
    }
    
    func testCountNotification() {
        let date = Timestamp(date: Date.now)
        
        let data1 = ["id": "notificationId1",
                    "uid": "userUid",
                    "kind": Int(NotificationKind.likeCaseReply.rawValue),
                    "timestamp": date,
                    "contentId": "contentId1",
                    "path": ["path1", "path2"]
        ] as [String : Any]
        
        let data2 = ["id": "notificationId2",
                    "uid": "userUid",
                    "kind": Int(NotificationKind.likeCaseReply.rawValue),
                    "timestamp": date,
                    "contentId": "contentId2",
                    "path": ["path1", "path2"]
        ] as [String : Any]
        
        let notification1 = Notification(dictionary: data1)
        let notification2 = Notification(dictionary: data2)
        
        sut.save(notification: notification1)
        sut.save(notification: notification2)
        
        let notifications = sut.getNotifications()
        
        XCTAssertEqual(notifications.count, 2)
    }
    
    func testLargeGroupNotifications() {
        let date = Timestamp(date: Date.now)
        
        let data = ["id": "notificationId1",
                    "uid": "userUid",
                    "kind": Int(NotificationKind.likeCaseReply.rawValue),
                    "timestamp": date,
                    "contentId": "contentId1",
                    "path": ["path1", "path2"]
        ] as [String : Any]
        
        let notification = Notification(dictionary: data)
        
        for _ in 0 ... 11 {
            sut.save(notification: notification)
        }
        
        let notifications = sut.getNotifications()
        
        XCTAssertEqual(notifications.count, 10)
    }
    
    func testLastNotificationDate() {
        let date = Timestamp(date: Date.now)
        
        let data = ["id": "notificationId1",
                    "uid": "userUid",
                    "kind": Int(NotificationKind.likeCaseReply.rawValue),
                    "timestamp": date,
                    "contentId": "contentId1",
                    "path": ["path1", "path2"]
        ] as [String : Any]
        
        let notification = Notification(dictionary: data)
        sut.save(notification: notification)
        
        let lastDate = sut.getLastNotificationDate()
        
        XCTAssertEqual(lastDate, date.dateValue())
    }
    
    func testGetNotificationsWithDate() {
        let date = Timestamp(date: Date.now)
        
        let oldData = ["id": "notificationId1",
                    "uid": "userUid",
                    "kind": Int(NotificationKind.likeCaseReply.rawValue),
                       "timestamp": Timestamp(date: Calendar.current.date(byAdding: .second, value: -3600, to: Date.now)!),
                    "contentId": "contentId1",
                    "path": ["path1", "path2"]
        ] as [String : Any]
        
        let newData = ["id": "notificationId1",
                    "uid": "userUid",
                    "kind": Int(NotificationKind.likeCaseReply.rawValue),
                       "timestamp": Timestamp(date: Date.now),
                    "contentId": "contentId1",
                    "path": ["path1", "path2"]
        ] as [String : Any]
        
        let oldNotification = Notification(dictionary: oldData)
        let newNotification = Notification(dictionary: newData)
        
        sut.save(notification: oldNotification)
        sut.save(notification: newNotification)
        
        let notifications = sut.getNotifications(before: date.dateValue(), limit: 10)
        XCTAssertEqual(notifications.count, 1)
    }
    
    func testLastNotificationWithDate() {
        let date = Timestamp(date: Date.now)
        
        let data = ["id": "notificationId1",
                    "uid": "userUid",
                    "kind": Int(NotificationKind.likeCaseReply.rawValue),
                    "timestamp": date,
                    "contentId": "contentId1",
                    "path": ["path1", "path2"]
        ] as [String : Any]
        
        let notification = Notification(dictionary: data)
        sut.save(notification: notification)
        
        let lastDate = sut.getLastNotificationDate()
        XCTAssertEqual(lastDate, date.dateValue())
    }
    
    func testSameNotificationDate() {
        let date = Timestamp(date: Date.now)
        
        let data = ["id": "notificationId1",
                    "uid": "userUid",
                    "kind": Int(NotificationKind.likeCaseReply.rawValue),
                    "timestamp": date,
                    "contentId": "contentId1",
                    "path": ["path1", "path2"]
        ] as [String : Any]
        
        let notification = Notification(dictionary: data)
        sut.save(notification: notification)
        
        let lastDate = sut.getLastDate(forContentId: "contentId1", withKind: .likeCaseReply)
        XCTAssertEqual(lastDate, date.dateValue())
    }
    
    func testInvalidTestNotification() {
        let lastDate = sut.getLastDate(forContentId: "contentId1", withKind: .likeCaseReply)
        XCTAssertNil(lastDate)
    }
    
    func testReadNotification() {
        let date = Timestamp(date: Date.now)
        
        let data = ["id": "notificationId1",
                    "uid": "userUid",
                    "kind": Int(NotificationKind.likeCaseReply.rawValue),
                    "timestamp": date,
                    "contentId": "contentId1",
                    "path": ["path1", "path2"]
        ] as [String : Any]
        
        var notification = Notification(dictionary: data)
        notification.set(isRead: false)
        
        XCTAssertEqual(notification.isRead, false)
        
        sut.save(notification: notification)
        
        sut.read(notification: notification)
        
        let notifications = sut.getNotifications()
        
        XCTAssertEqual(notifications.first?.isRead, true)
    }
    
    func testEditNotification() {
        let date = Timestamp(date: Date.now)
        
        let data = ["id": "notificationId1",
                    "uid": "userUid",
                    "kind": Int(NotificationKind.likeCaseReply.rawValue),
                    "timestamp": date,
                    "contentId": "contentId1",
                    "path": ["path1", "path2"]
        ] as [String : Any]
        
        var notification = Notification(dictionary: data)
        notification.set(content: "Content of the notification")
        
        XCTAssertEqual(notification.isRead, false)
        
        sut.save(notification: notification)
        
        sut.edit(notification: notification, set: "New Content", forKey: "content")
        
        let notifications = sut.getNotifications()
        
        XCTAssertEqual(notifications.first?.content, "New Content")
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

            if let error = error {
                fatalError("Create an in-mem coordinator failed \(error)")
            }
        }
        return container
    }()
}

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const db = admin.firestore();

/*
------
TODO: Send Connection Push Notification
*/

/*
----------------
enum ConnectPhase: Int {

    case connected, pending, received, rejected, withdraw, unconnect, none
    
----------------
*/

/*
----------------

    case likePost = 1
    case replyPost = 11
    case replyPostComment = 21
    case likePostReply = 31
    
    case likeCase = 101
    case replyCase = 111
    case replyCaseComment = 121
    case likeCaseReply = 131

    case caseApprove = 201
    
    case connectionAccept = 301
    case connectionRequest = 311

    --------------
*/

exports.firestoreConnectionsOnCreate = functions.region('europe-west1').firestore.document('connections/{userId}/user-connections/{connectedUserId}').onCreate(async (snapshot, context) => {
    const userId = context.params.userId;
    const connectedUserId = context.params.connectedUserId;

    let data = snapshot.data();
    let phase = data.phase;
    let timestamp = data.timestamp;

    const timestampData = {
        timestamp: timestamp
    };

    const promises = [];

    if (phase === 2) {
        // userId receives the request from connectedUserId, so the userId gets also a new follower -> connectedUserId
        promises.push(addFollower(userId, connectedUserId, timestampData));
        promises.push(addNotification(userId, connectedUserId, snapshot));

    } else if (phase === 1) {
        // userId sends a request to connectedUserId, so the userId also follows a new user -> connectedUserId
        promises.push(addFollowing(userId, connectedUserId, timestampData));
    }

    // Wait for all promises to resolve
    await Promise.all(promises);

    console.log('All operations completed successfully');
});

async function addFollower(userId, connectedUserId, timestampData) {
    const followersRef = admin.firestore().collection(`followers/${userId}/user-followers`);
    await followersRef.doc(connectedUserId).set(timestampData);
}

async function addFollowing(userId, connectedUserId, timestampData) {
    const followingRef = admin.firestore().collection(`following/${userId}/user-following`);
    await followingRef.doc(connectedUserId).set(timestampData);
}

async function addNotification(userId, connectionId, snapshot) {
    
    const data = snapshot.data();

    const kind = 311;
    const timestamp = admin.firestore.Timestamp.now();
    const notificationData = {
        kind: kind,
        timestamp: timestamp,
        uid: connectionId,
    };

    const userNotificationsRef = admin
        .firestore()
        .collection('notifications')
        .doc(userId)
        .collection('user-notifications');

    const notificationRef = await userNotificationsRef.add(notificationData);
    const notificationId = notificationRef.id;

    await notificationRef.update({ id: notificationId });
    console.log("Firestore connection notification added", userId, connectionId);
};

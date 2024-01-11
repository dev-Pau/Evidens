const functions = require('firebase-functions');
const admin = require('firebase-admin');
const db = admin.firestore();

/*
---------------
TODO:
    - Send Push Notification for Like Notification

---------------
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

exports.httpsCommentsPostsOnCall = functions.https.onCall(async (data, context) => {
    const postId = data.postId;
    const path = data.path;
    const timestamp = admin.firestore.Timestamp.fromMillis(data.timestamp * 1000);
    const uid = data.uid;
    const id = data.id;
    const owner = data.owner;

    const kind = 21;

    const notificationData = {
        path: path.concat(id),
        contentId: postId,
        kind: kind,
        timestamp: timestamp,
        uid: uid,
    };

    const userNotificationsRef = admin
        .firestore()
        .collection('notifications')
        .doc(owner)
        .collection('user-notifications');

    const notificationRef = await userNotificationsRef.add(notificationData);
    const notificationId = notificationRef.id;

    await notificationRef.update({ id: notificationId });
});

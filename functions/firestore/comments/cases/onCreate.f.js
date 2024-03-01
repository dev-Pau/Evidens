const functions = require('firebase-functions');
const admin = require('firebase-admin');

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

exports.firestoreCommentsCasesOnCreate = functions.region('europe-west1').firestore.document('cases/{caseId}/comments/{commentId}').onCreate(async (snapshot, context) => {
    const caseId = context.params.caseId;
    const commentId = context.params.commentId;

    const userId = snapshot.data().uid;

    const commentTimestamp = snapshot.data().timestamp;

    const caseSnapshot = await admin.firestore().collection('cases').doc(caseId).get();

    const ownerUid = caseSnapshot.data().uid;
    const content = caseSnapshot.data().title;
    const postTimestamp = caseSnapshot.data().timestamp;

    const kind = 111;

    if (userId == ownerUid) {
        // Like from owner of the post
        return;
    }
    
    const timestamp = admin.firestore.Timestamp.now();

    const notificationData = {
        path: [commentId],
        contentId: caseId,
        kind: kind,
        timestamp: commentTimestamp,
        uid: userId,
    };

    const userNotificationsRef = admin
        .firestore()
        .collection('notifications')
        .doc(ownerUid)
        .collection('user-notifications');

    const notificationRef = await userNotificationsRef.add(notificationData);
    const notificationId = notificationRef.id;

    await notificationRef.update({ id: notificationId });
    //TODO: Send Push Notification
});
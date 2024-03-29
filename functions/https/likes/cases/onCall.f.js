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

exports.httpsLikesCasesCommentOnCall = functions.region('europe-west1').https.onCall(async (data, context) => {
    const caseId = data.caseId;
    const path = data.path;
    const timestamp = admin.firestore.Timestamp.fromMillis(data.timestamp * 1000);
    const id = data.id;
    const owner = data.owner;
    const kind = 131;
    const uid = data.uid;

    const existingNotificationQuerySnapshot = await admin
        .firestore()
        .collection('notifications')
        .doc(owner)
        .collection('user-notifications')
        .where('contentId', '==', caseId)
        .where('commentId', '==', id)
        .where('kind', '==', kind)
        .get();

    if (existingNotificationQuerySnapshot.empty) {
        /*
        If there's no notification, means that it's the first like for this comment or;
        The owner deleted the notification and is receiving new likes.
        Either way, we create a new notification with this user's data and notify the receiver.
        */

        const notificationData = {
            path: path.concat(id),
            contentId: caseId,
            commentId: id,
            kind: kind,
            timestamp: timestamp,
        };

        if (uid !== undefined) {
            notificationData.uid = uid;
        }

        const userNotificationsRef = admin
            .firestore()
            .collection('notifications')
            .doc(owner)
            .collection('user-notifications');

        const notificationRef = await userNotificationsRef.add(notificationData);
        const notificationId = notificationRef.id;
        notificationRef.update({ id: notificationId });
    } else {

        const existingNotificationDocRef = existingNotificationQuerySnapshot.docs[0].ref;

        if (uid !== undefined) {
            await existingNotificationDocRef.update(
                {
                    timestamp: timestamp,
                    uid: uid,
                });
        } else {
            await existingNotificationDocRef.update(
                {
                    timestamp: timestamp,
                });
        }
    }
});
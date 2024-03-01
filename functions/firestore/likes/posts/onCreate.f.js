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

exports.firestoreLikesPostsOnCreate = functions.region('europe-west1').firestore.document('posts/{postId}/post-likes/{userId}').onCreate(async (snapshot, context) => {
    const postId = context.params.postId;
    const userId = context.params.userId;

    const likeTimestamp = snapshot.data().timestamp;

    const postSnapshot = await admin.firestore().collection('posts').doc(postId).get();

    const uid = postSnapshot.data().uid;
    const content = postSnapshot.data().post;
    const postTimestamp = postSnapshot.data().timestamp;

    if (userId == uid) {
        // Like from the owner of the post
        return;
    }

    const kind = 1;

    const existingNotificationQuerySnapshot = await admin
        .firestore()
        .collection('notifications')
        .doc(uid)
        .collection('user-notifications')
        .where('contentId', '==', postId)
        .where('kind', '==', kind)
        .get();

    if (existingNotificationQuerySnapshot.empty) {
        /*
        If there's no notification, means that it's the first like for this post or;
        The owner deleted the notification and is receiving new likes.
        Either way, we create a new notification with this user's data and notify the receiver.
        */

        const notificationData = {
            contentId: postId,
            kind: kind,
            timestamp: likeTimestamp,
            uid: userId,
            notified: likeTimestamp,
        };

        const userNotificationsRef = admin
            .firestore()
            .collection('notifications')
            .doc(uid)
            .collection('user-notifications');

        const notificationRef = await userNotificationsRef.add(notificationData);
        const notificationId = notificationRef.id;

        await notificationRef.update({ id: notificationId });
    } else {
        /*
        There's already a like kind notification for this post;
        Update the the most recent userId with the corresponding timestamp;
        */
        const existingNotificationDocRef = existingNotificationQuerySnapshot.docs[0].ref;
        const existingNotificationData = existingNotificationQuerySnapshot.docs[0].data();

        const notificationId = existingNotificationData.notificationId;

        const timestamp = admin.firestore.Timestamp.now();

        await existingNotificationDocRef.update(
            {
                timestamp: likeTimestamp,
                uid: userId,
            }
        );
    }
});


exports.firestoreLikesPostsCommentsOnCreate = functions.region('europe-west1').firestore.document('posts/{postId}/comments/{commentId}/likes/{userId}').onCreate(async (snapshot, context) => {
    const postId = context.params.postId;
    const commentId = context.params.commentId;
    const userId = context.params.userId;

    const likeTimestamp = snapshot.data().timestamp;

    const commentSnapshot = await admin.firestore().collection('posts').doc(postId).collection('comments').doc(commentId).get();
    const uid = commentSnapshot.data().uid;

    const kind = 31;

    if (userId == uid) {
        // Prevent notifications from the owner of the post
        return;
    }

    const existingNotificationQuerySnapshot = await admin
        .firestore()
        .collection('notifications')
        .doc(uid)
        .collection('user-notifications')
        .where('contentId', '==', postId)
        .where('path', 'array-contains', commentId)
        .where('kind', '==', kind)
        .get();

    if (existingNotificationQuerySnapshot.empty) {
        /*
        If there's no notification, means that it's the first like for this comment or;
        The owner deleted the notification and is receiving new likes.
        Either way, we create a new notification with this user's data and notify the receiver.
        */

        const notificationData = {
            path: [commentId],
            contentId: postId,
            kind: kind,
            timestamp: likeTimestamp,
            uid: userId,
        };

        const userNotificationsRef = admin
            .firestore()
            .collection('notifications')
            .doc(uid)
            .collection('user-notifications');

        const notificationRef = await userNotificationsRef.add(notificationData);
        const notificationId = notificationRef.id;

        await notificationRef.update({ id: notificationId });
    } else {

        const existingNotificationDocRef = existingNotificationQuerySnapshot.docs[0].ref;
        const existingNotificationData = existingNotificationQuerySnapshot.docs[0].data();

        await existingNotificationDocRef.update(
            {
                timestamp: likeTimestamp,
                uid: userId,
            }
        );
    }
});

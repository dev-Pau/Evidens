const functions = require('firebase-functions');
const admin = require('firebase-admin');


/*
  ******************************************
  *                                        *
  *                RELEASE                 *
  *            !!  CAUTION !!              *
  *                                        *
  ******************************************
*/


exports.releaseFirestoreLikesCasesOnCreate = functions.firestore.document('cases/{caseId}/case-likes/{userId}').onCreate(async (snapshot, context) => {
    const caseId = context.params.caseId;
    const userId = context.params.userId;

    const likeTimestamp = snapshot.data().timestamp;

    const caseSnapshot = await admin.firestore().collection('cases').doc(caseId).get();

    const ownerUid = caseSnapshot.data().uid;
    const content = caseSnapshot.data().title;
    const caseTimestamp = caseSnapshot.data().timestamp;

    if (userId == ownerUid) {
        // Like from owner of the case
        return;
    }

    const kind = 101;

    const existingNotificationQuerySnapshot = await admin
        .firestore()
        .collection('notifications')
        .doc(ownerUid)
        .collection('user-notifications')
        .where('contentId', '==', caseId)
        .where('kind', '==', kind)
        .get();

    if (existingNotificationQuerySnapshot.empty) {
        /*
        If there's no notification, means that it's the first like for this post or;
        The owner deleted the notification and is receiving new likes.
        Either way, we create a new notification with this user's data and notify the receiver.
        */

        const notificationData = {
            contentId: caseId,
            kind: kind,
            timestamp: likeTimestamp,
            uid: userId,
            notified: likeTimestamp,
        };

        const userNotificationsRef = admin
            .firestore()
            .collection('notifications')
            .doc(ownerUid)
            .collection('user-notifications');

        const notificationRef = await userNotificationsRef.add(notificationData);
        const notificationId = notificationRef.id;

        await notificationRef.update({ id: notificationId });

    } else {

        const existingNotificationDocRef = existingNotificationQuerySnapshot.docs[0].ref;
        const existingNotificationData = existingNotificationQuerySnapshot.docs[0].data();

        const notificationId = existingNotificationData.notificationId;
        const timestamp = admin.firestore.FieldValue.serverTimestamp()

        await existingNotificationDocRef.update(
            {
                timestamp: likeTimestamp,
                uid: userId,
            }
        );
    }
});


/*
  ******************************************
  *                                        *
  *                RELEASE                 *
  *            !!  CAUTION !!              *
  *                                        *
  ******************************************
*/


exports.releaseFirestoreLikesCasesCommentOnCreate = functions.firestore.document('cases/{caseId}/comments/{commentId}/likes/{userId}').onCreate(async (snapshot, context) => {
    const caseId = context.params.caseId;
    const commentId = context.params.commentId;
    const userId = context.params.userId;

    const likeTimestamp = snapshot.data().timestamp;

    const commentSnapshot = await admin.firestore().collection('cases').doc(caseId).collection('comments').doc(commentId).get();
    const caseSnapshot = await admin.firestore().collection('cases').doc(caseId).get();

    const uid = commentSnapshot.data().uid;

    const visible = caseSnapshot.data().privacy;
    const caseUid = caseSnapshot.data().uid;

    const kind = 131;

    if (userId == uid) {
        // Prevent notifications from the owner of the post
        return;
    }

    const existingNotificationQuerySnapshot = await admin
        .firestore()
        .collection('notifications')
        .doc(uid)
        .collection('user-notifications')
        .where('contentId', '==', caseId)
        .where('commentId', '==', commentId)
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
            contentId: caseId,
            kind: kind,
            timestamp: likeTimestamp,
        };

        if (visible == 1 && userId == caseUid) {
        } else {
            notificationData.uid = userId;
        }

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

        if (visible == 1 && userId == caseUid) {
            await existingNotificationDocRef.update(
                {
                    timestamp: likeTimestamp,
                }
            );
        } else {
            await existingNotificationDocRef.update(
                {
                    timestamp: likeTimestamp,
                    uid: userId,
                }
            );
        }
    }
});


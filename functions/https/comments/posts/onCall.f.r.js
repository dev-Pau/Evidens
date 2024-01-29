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


exports.releaseHttpsCommentsPostsOnCall = functions.https.onCall(async (data, context) => {
    const postId = data.postId;
    const path = data.path;
    const timestamp = admin.firestore.Timestamp.fromMillis(data.timestamp * 1000);
    const uid = data.uid;
    const id = data.id;
    const owner = data.owner;

    const kind = 21;

    const notificationData = {
        path: path,
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

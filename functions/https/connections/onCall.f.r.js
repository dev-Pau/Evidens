const functions = require('firebase-functions');
const admin = require('firebase-admin');
const db = admin.firestore();

/*
  ******************************************
  *                                        *
  *                RELEASE                 *
  *            !!  CAUTION !!              *
  *                                        *
  ******************************************
*/


exports.releaseHttpsConnectionsOnCallAcceptConnection = functions.region('europe-west1').https.onCall(async (data, context) => {
    const userId = data.userId;
    const name = data.name;
    const uid = data.uid;

    const timestamp = admin.firestore.Timestamp.now();

    const timestampData = {
        timestamp: timestamp
    };

    const followersRef = db.collection(`followers/${userId}/user-followers`);
    await followersRef.doc(uid).set(timestampData);

    const followingRef = db.collection(`following/${uid}/user-following`);
    await followingRef.doc(userId).set(timestampData);

    const notificationData = {
        kind: 301,
        timestamp: timestamp,
        uid: uid,
    };

    const userNotificationsRef = admin
        .firestore()
        .collection('notifications')
        .doc(userId)
        .collection('user-notifications');

    const notificationRef = await userNotificationsRef.add(notificationData);
    const notificationId = notificationRef.id;

    await notificationRef.update({ id: notificationId });
    //TODO: Send Accept Connection Push Notification
});

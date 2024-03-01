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


exports.releaseFirestoreConnectionsOnCreate = functions.region('europe-west1').firestore.document('connections/{userId}/user-connections/{connectedUserId}').onCreate(async (snapshot, context) => {
    const userId = context.params.userId;
    const connectedUserId = context.params.connectedUserId;

    let data = snapshot.data();
    let phase = data.phase;
    let timestamp = data.timestamp;

    const timestampData = {
        timestamp: timestamp
    };

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

    const notificationQuery = await admin
        .firestore()
        .collection('notifications')
        .doc(userId)
        .collection('user-notifications')
        .where('kind', '==', kind)
        .where('uid', '==', connectionId)
        .get();

    /*
        If there's no notification, means that it's the first time this users established connection or;
        It was from user's network previously but they break relationship somehow and want to connect again.
        Either way, we create a new notification with this user's data and notify the receiver.
    */

    if (notificationQuery.empty) {

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
        //TODO: Send Notification Here

    } else {
        /*
        If the notification exists, the user still hasn't fetched it.
        In this case, we just update the timestamp but we don't send any notification, as it has been sent previoiusly
        */
        const existingNotificationDocRef = existingNotificationQuerySnapshot.docs[0].ref;
        const existingNotificationData = existingNotificationQuerySnapshot.docs[0].data();

        const notificationId = existingNotificationData.notificationId;

        const timestamp = admin.firestore.Timestamp.now()

        await existingNotificationDocRef.update(
            {
                timestamp: timestamp,
                uid: connectionId,
            }
        );

        console.log("Firestore connection notification updated", userId, connectionId);
    }
};

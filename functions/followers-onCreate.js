const functions = require('firebase-functions');
const admin = require('firebase-admin');

const db = admin.firestore();

exports.addNotificationOnNewFollow = functions.firestore.document('followers/{userId}/user-followers/{followerId}').onCreate(async (snapshot, context) => {
    const followerId = context.params.followerId;
    const userId = context.params.userId;

    const kind = 2;

    // Check if the notification already exists
    const existingNotificationQuerySnapshot = await admin
        .firestore()
        .collection('notifications')
        .doc(userId)
        .collection('user-notifications')
        .where('kind', '==', kind)
        .where('uid', '==', followerId)
        .get();

    if (existingNotificationQuerySnapshot.empty) {
        /*
        If there's no notification, means that it's the first time this user established connection or;
        It was from user's network previously but they break relationship somehow and want to connect again.
        Either way, we create a new notification with this user's data and notify the receiver.
        */

        const timestamp = admin.firestore.Timestamp.now();
        const notificationData = {
            kind: kind,
            timestamp: timestamp,
            uid: followerId,
        };

        const userNotificationsRef = admin
            .firestore()
            .collection('notifications')
            .doc(userId)
            .collection('user-notifications');

        const notificationRef = await userNotificationsRef.add(notificationData);
        const notificationId = notificationRef.id;

        await notificationRef.update({ id: notificationId });
        await sendFollowPushNotification(userId, followerId);

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
                uid: followerId,
            }
        );
    }
});


/// Helpers

async function sendFollowPushNotification(ownerUid, userId) {

    const preferencesRef = db.collection('notifications').doc(ownerUid);
    const preferencesSnapshot = await preferencesRef.get();
    const preferences = preferencesSnapshot.data();

    // Stop execution if notifications are disabled for the user
    if (!preferences.enabled) {
        console.log('Notifications disabled', ownerUid);
        return;
    }

    // Stop execution if user don't want to receive follow notifications
    if (!preferences.follower) {
        console.log('User dont to receive following notifications:', ownerUid);
        return;
    }

    const userRef = admin.firestore().collection('users').doc(userId);
    const userSnapshot = await userRef.get();
    const user = userSnapshot.data();

    const firstName = user.firstName;
    const lastName = user.lastName;

    const title = `${firstName} ${lastName}`;

    const tokenSnapshot = await admin.database().ref(`/tokens/${ownerUid}`).once('value');
    const tokenData = tokenSnapshot.val();

    const code = preferences.code;

    let body = "is now following you";

    switch (code) {
        case "es":
            body = "ara et segueix";
            break;
        
        case "ca":
            body = 'ahora te está siguiendo';
            break;
    }

    const message = {
        notification: {
            title: title,
            body: body
        },
        token: tokenData,
    };

    admin.messaging().send(message);
    functions.logger.log('Notifications sent');
};


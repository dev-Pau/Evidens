const functions = require('firebase-functions');
const admin = require('firebase-admin');

const db = admin.firestore();

exports.addNotificationOnNewConnection = functions.firestore.document('connections/{userId}/user-connections/{connectionId}').onCreate(async (snapshot, context) => {
    const connectionId = context.params.connectionId;
    const userId = context.params.userId;
    const data = snapshot.data();

    if (data.phase !== 2) {
        console.log('This is not the user that received the connection request', userId);
        return
    }

    const kind = 2;
    console.log('This is the user that received the connection request', userId);
    // Check if the notification already exists
    const existingNotificationQuerySnapshot = await admin
        .firestore()
        .collection('notifications')
        .doc(userId)
        .collection('user-notifications')
        .where('kind', '==', kind)
        .where('uid', '==', connectionId)
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
        await sendFollowPushNotification(userId, connectionId);

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

    let body = "is inviting you to connect";

    switch (code) {
        case "es":
            body = "et convida a connectar";
            break;
        
        case "ca":
            body = "te está invitando a conectar";
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


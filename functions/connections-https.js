const functions = require('firebase-functions');
const admin = require('firebase-admin');

const db = admin.firestore();

exports.addNotificationOnAcceptConnection = functions.https.onCall(async (data, context) => {
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
        kind: 9,
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
    await sendConnectionAcceptedNotification(userId, name);
});

/// Helpers

async function sendConnectionAcceptedNotification(userId, name) {

    const preferencesRef = db.collection('notifications').doc(userId);
    const preferencesSnapshot = await preferencesRef.get();
    const preferences = preferencesSnapshot.data();

    // Stop execution if notifications are disabled for the user
    if (!preferences.enabled) {
        console.log('Notifications disabled', userId);
        return;
    }

    // Stop execution if user don't want to receive follow notifications
    if (!preferences.follower) {
        console.log('User dont to receive connection notifications:', userId);
        return;
    }

    const userRef = admin.firestore().collection('users').doc(userId);
    const userSnapshot = await userRef.get();
    const user = userSnapshot.data();

    const title = name;

    const tokenSnapshot = await admin.database().ref(`/tokens/${userId}`).once('value');
    const tokenData = tokenSnapshot.val();

    const code = preferences.code;

    let body = "has accepted your connection request";

    switch (code) {
        case "es":
            body = "ha aceptado tu invitación de conexión";
            break;
        
        case "ca":
            body = "ha acceptat la teva petició de connexió";
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


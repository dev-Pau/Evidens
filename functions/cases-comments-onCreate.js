const functions = require('firebase-functions');
const admin = require('firebase-admin');

const db = admin.firestore();

exports.addNotificationOnCaseComment = functions.firestore.document('cases/{caseId}/comments/{commentId}').onCreate(async (snapshot, context) => {
    const caseId = context.params.caseId;
    const commentId = context.params.commentId;
    // Owner of the comment
    const userId = snapshot.data().uid;

    const commentTimestamp = snapshot.data().timestamp;

    const caseSnapshot = await admin.firestore().collection('cases').doc(caseId).get();
    // Owner of the post
    const ownerUid = caseSnapshot.data().uid;
    const content = caseSnapshot.data().title;
    const postTimestamp = caseSnapshot.data().timestamp;

    const kind = 4;
    if (userId == ownerUid) {
        // Like from owner of the post
        return;
    }
        const timestamp = admin.firestore.Timestamp.now();
        // Create a new notification document
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
        // Update the notification document with the generated ID
        await notificationRef.update({ id: notificationId });
        await sendCommentPushNotification(ownerUid, userId, content)
});


exports.addNotificationOnCaseReply = functions.https.onCall(async (data, context) => {
    const caseId = data.caseId;
    const path = data.path;
    const timestamp = admin.firestore.Timestamp.fromMillis(data.timestamp * 1000);
    const uid = data.uid;
    const id = data.id;
    const owner = data.owner;

    const kind = 6;

    // Now you can use the received data to perform any desired actions
    console.log("Received Data - PostId:", caseId);
    console.log("Received Data - Path:", path);
    console.log("Received Data - Timestamp:", timestamp);
    console.log("Received Data - UID:", uid);
    console.log("Received Data - ID:", id);
    console.log("Received Data - Owner:", owner);

    const notificationData = {
        path: path,
        contentId: caseId,
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
    // Update the notification document with the generated ID
    await notificationRef.update({ id: notificationId });
    //await sendCommentPushNotification(ownerUid, userId, content);

    // Now you can use the received data to perform any desired actions
    // For example, you can save this data to Firestore or Realtime Database

    // You can also return a response to your iOS app if needed
    /*
    return {
        success: true,
        message: 'Notification added successfully',
    };
    */
});



/// Helpers

async function sendCommentPushNotification(ownerUid, userId, content) {

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

    if (!preferences.reply.value) {
        console.log('user dont to receive reply notifications:', ownerUid);
        return;
    }
    if (preferences.reply.target === 0) {
        // Only notifications from user's network
        console.log('user wants to receive notifications only from followers:', ownerUid);
        const followingRef = admin.firestore().collection(`following/${ownerUid}/user-following`);
        const followingSnapshot = await followingRef.doc(userId).get();

        if (!followingSnapshot.exists) {
            console.log('User is not being followed by the owner. Notification will not be sent.');
            return;
        }
    }

    const code = preferences.code;
    
    title = `${firstName} ${lastName} replied:`;

    const tokenSnapshot = await admin.database().ref(`/tokens/${ownerUid}`).once('value');
    const tokenData = tokenSnapshot.val();

    switch (code) {
        case "es":
            title = `${firstName} ${lastName} ha respondido:`;
            break;
        
        case "ca":
            title = `${firstName} ${lastName} ha respost:`;
            break;
    }

    const message = {
        notification: {
            title: title,
            body: content
        },
        token: tokenData,
    };

    admin.messaging().send(message);
    functions.logger.log('Notifications sent');
};






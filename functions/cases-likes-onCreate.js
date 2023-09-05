const functions = require('firebase-functions');
const admin = require('firebase-admin');

const db = admin.firestore();

const { sendNotification } = require('./notifications');


exports.addNotificationOnCaseLike = functions.firestore.document('cases/{caseId}/case-likes/{userId}').onCreate(async (snapshot, context) => {
    const caseId = context.params.caseId;
    const userId = context.params.userId;

    const likeTimestamp = snapshot.data().timestamp;

    // Get the uid from the caseId document. This uid corresponds to the owner of the case and will also be the notification target uid.
    const caseSnapshot = await admin.firestore().collection('cases').doc(caseId).get();
    const ownerUid = caseSnapshot.data().uid;

    const content = caseSnapshot.data().title;
    const caseTimestamp = caseSnapshot.data().timestamp;

    if (userId == ownerUid) {
        // Like from owner of the case
        return;
    }

    const kind = 1;

    // Check if a notification with the same contentId and kind exists
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

        // Create a new notification document
        const notificationData = {
            contentId: caseId,
            kind: kind,
            timestamp: likeTimestamp,
            uid: userId,
        };

        const userNotificationsRef = admin
            .firestore()
            .collection('notifications')
            .doc(ownerUid)
            .collection('user-notifications');

        const notificationRef = await userNotificationsRef.add(notificationData);
        const notificationId = notificationRef.id;

        await notificationRef.update({ id: notificationId });
        console.log('Case like notification added to user:', ownerUid);

        const timeDifferenceInSeconds = likeTimestamp - caseTimestamp.seconds
        if (timeDifferenceInSeconds >= 60) {
            await notificationRef.update({ notified: notificationData.timestamp });
            await sendLikeNotification(ownerUid, userId, content, caseId)
        }
    } else {
        // Update the existing notification document
        const existingNotificationDocRef = existingNotificationQuerySnapshot.docs[0].ref;
        const existingNotificationData = existingNotificationQuerySnapshot.docs[0].data();

        const notificationId = existingNotificationData.notificationId;
        const timestamp = admin.firestore.FieldValue.serverTimestamp()

        if (!existingNotificationData.notified) {
            // Perform your specific action here
            console.log('User received likes within the first 60 seconds of the case');
            await existingNotificationDocRef.update(
                {
                    timestamp: likeTimestamp,
                    notified: timestamp,
                    uid: userId,
                }
            );
            await sendLikeNotification(ownerUid, userId, content, caseId);

        } else {
            await existingNotificationDocRef.update(
                {
                    timestamp: likeTimestamp,
                    uid: userId,
                }
            );
        }

        console.log('Case like notification updated:', ownerUid);
    }
});

exports.addNotificationOnCaseCommentLike = functions.firestore.document('cases/{caseId}/comments/{commentId}/likes/{userId}').onCreate(async (snapshot, context) => {
    const caseId = context.params.caseId;
    const commentId = context.params.commentId;
    const userId = context.params.userId;

    const likeTimestamp = snapshot.data().timestamp;

    // Get the uid from the caseId document. This uid corresponds to the owner of the post and will also be the notification target uid.
    const commentSnapshot = await admin.firestore().collection('cases').doc(caseId).collection('comments').doc(commentId).get();
    const caseSnapshot = await admin.firestore().collection('cases').doc(caseId).get();

    const uid = commentSnapshot.data().uid;

    const visible = caseSnapshot.data().privacy;
    const caseUid = caseSnapshot.data().uid;

    const kind = 8;
    // If the person who sent the notification  = owner of comment
    if (userId == uid) {
        // Prevent notifications from the owner of the post
        return;
    }

    // Check if a notification with the same kind and post exists
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

        // Create a new notification document
        const notificationData = {
            path: [commentId],
            contentId: caseId,
            kind: kind,
            timestamp: likeTimestamp,
        };

        if (visible == 1 && userId == caseUid) {
            console.log('ANONYMOUS AND OWNER', userId);
        } else {
            console.log('NO OWNER OR NO ANONYMOUS', userId);
            notificationData.uid = userId;
        }


        const userNotificationsRef = admin
            .firestore()
            .collection('notifications')
            .doc(uid)
            .collection('user-notifications');

        const notificationRef = await userNotificationsRef.add(notificationData);
        const notificationId = notificationRef.id;
        // Update the notification document with the generated ID
        await notificationRef.update({ id: notificationId });
    } else {
        // Update the existing notification document
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


exports.addNotificationOnCaseLikeReply = functions.https.onCall(async (data, context) => {
    const caseId = data.caseId;
    const path = data.path;
    const timestamp = admin.firestore.Timestamp.fromMillis(data.timestamp * 1000);
    const id = data.id;
    const owner = data.owner;
    const kind = 8;
    const uid = data.uid;

    // Now you can use the received data to perform any desired actions
    console.log("Received Data - postId:", caseId);
    console.log("Received Data - Path:", path);
    console.log("Received Data - Timestamp:", timestamp);
    console.log("Received Data - ID:", id);
    console.log("Received Data - Owner:", owner);
    console.log("Received Data - commentId:", id);
    console.log("Received Data - UID:", data.uid);
    // Check if a notification with the same kind and post exists

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

        // Create a new notification document
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
        // Update the notification document with the generated ID
        await notificationRef.update({ id: notificationId });
    } else {
        // Update the existing notification document
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



async function sendLikeNotification(ownerUid, userId, content, contentId) {

    const preferencesRef = db.collection('notifications').doc(ownerUid);
    const preferencesSnapshot = await preferencesRef.get();
    const preferences = preferencesSnapshot.data();

    if (!preferences.enabled) {
        // Stop execution if notifications are disabled for the user
        console.log('Notifications disabled', ownerUid);
        return;
    }

    if (!preferences.like.value) {
        console.log('user dont to receive like notifications:', ownerUid);
        return;
    }

    if (preferences.like.target === 0) {
        // Only notifications from user's network
        console.log('user wants to receive notifications only from followers:', ownerUid);
        const followingRef = admin.firestore().collection(`following/${ownerUid}/user-following`);
        const followingSnapshot = await followingRef.doc(userId).get();

        if (!followingSnapshot.exists) {
            console.log('User is not being followed by the owner. Notification will not be sent.');
            return;
        }
        console.log('User is beeing followed. Notification will be sent:', ownerUid);
    } else {
        console.log('user wants to receive notifications from everyone:', ownerUid);
    }

    // Here before fetching user checking that if only wants to get notified by users that folllowrers, updat eit
    console.log('user that is sendign notification:', userId);
    const userRef = admin.firestore().collection('users').doc(userId);
    const userSnapshot = await userRef.get();
    const user = userSnapshot.data();

    const firstName = user.firstName;
    const lastName = user.lastName;


    const code = preferences.code;

    let title = "";

    const tokenSnapshot = await admin.database().ref(`/tokens/${ownerUid}`).once('value');
    const tokenData = tokenSnapshot.val();

    functions.logger.log('Retrieving case likes');
    const caseLikesRef = admin.firestore().collection(`cases/${contentId}/case-likes`);
    const caseLikesSnapshot = await caseLikesRef.get();
    const updatedLikeCaseCount = caseLikesSnapshot.size;

    if (updatedLikeCaseCount === 1) {

        title = `Liked by ${firstName} ${lastName}:`;

        switch (code) {
            case "es":
                title = `Le gusta a ${firstName} ${lastName}:`;
                break;

            case "ca":
                title = `Agrada a ${firstName} ${lastName}:`;
                break;
        }

    } else if (updatedLikeCaseCount === 2) {
        title = `Liked by ${firstName} ${lastName} and more:`;

        switch (code) {
            case "es":
                title = `Le gusta a ${firstName} ${lastName} y otros:`;
                break;

            case "ca":
                title = `Agrada a ${firstName} ${lastName} i altres:`;
                break;
        }

    } else if (updatedLikeCaseCount > 2) {
        const additionalCaseLikes = updatedLikeCaseCount - 1;
        title = `Liked by ${firstName} ${lastName} and ${additionalCaseLikes} others:`;

        switch (code) {
            case "es":
                title = `Le gusta a ${firstName} ${lastName} y a ${additionalCaseLikes} más:`;
                break;

            case "ca":
                title = `Agrada a ${firstName} ${lastName} i a ${additionalCaseLikes} més:`;
                break;
        }
    }

    // Send the notification
    const payload = {
        notification: {
            title: title,
            body: content
        }
    };

    await admin.messaging().sendToDevice(tokenData, payload);
    functions.logger.log('Notifications sent');
};

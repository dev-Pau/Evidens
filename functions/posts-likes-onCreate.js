const functions = require('firebase-functions');
const admin = require('firebase-admin');

const db = admin.firestore();

exports.addNotificationOnPostLike = functions.firestore.document('posts/{postId}/post-likes/{userId}').onCreate(async (snapshot, context) => {
    const postId = context.params.postId;
    const userId = context.params.userId

    const likeTimestamp = snapshot.data().timestamp;

    // Get the uid from the postId document. This uid corresponds to the owner of the post and will also be the notification target uid.
    const postSnapshot = await admin.firestore().collection('posts').doc(postId).get();
    const uid = postSnapshot.data().uid;

    const content = postSnapshot.data().post;
    const postTimestamp = postSnapshot.data().timestamp;

    const kind = 0;

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
        .where('contentId', '==', postId)
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
        // Update the notification document with the generated ID
        await notificationRef.update({ id: notificationId });
       
        const timeDifferenceInSeconds = likeTimestamp.seconds - postTimestamp.seconds
        if (timeDifferenceInSeconds >= 100) {
            await notificationRef.update({ notified: notificationData.timestamp });
            await sendLikeNotification(uid, userId, content, postId)
        }
    } else {
        // Update the existing notification document
        const existingNotificationDocRef = existingNotificationQuerySnapshot.docs[0].ref;
        const existingNotificationData = existingNotificationQuerySnapshot.docs[0].data();

        const notificationId = existingNotificationData.notificationId;
        
        const timestamp = admin.firestore.Timestamp.now();


        if (!existingNotificationData.notified) {

            await existingNotificationDocRef.update(
                {
                    timestamp: likeTimestamp,
                    notified: timestamp,
                    uid: userId,
                }
            );
            await sendLikeNotification(uid, userId, content, postId)

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


exports.addNotificationOnPostCommentLike = functions.firestore.document('posts/{postId}/comments/{commentId}/likes/{userId}').onCreate(async (snapshot, context) => {
    const postId = context.params.postId;
    const commentId = context.params.commentId;
    const userId = context.params.userId;

    const likeTimestamp = snapshot.data().timestamp;

    // Get the uid from the postId document. This uid corresponds to the owner of the post and will also be the notification target uid.
    const commentSnapshot = await admin.firestore().collection('posts').doc(postId).collection('comments').doc(commentId).get();
    const uid = commentSnapshot.data().uid;

    const kind = 7;

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

        // Create a new notification document
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
        // Update the notification document with the generated ID
        await notificationRef.update({ id: notificationId });
    } else {
        // Update the existing notification document
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

exports.addNotificationOnPostLikeReply = functions.https.onCall(async (data, context) => {
    const postId = data.postId;
    const path = data.path;

    const timestamp = admin.firestore.Timestamp.fromMillis(data.timestamp * 1000);
    const uid = data.uid;
    const id = data.id;
    const owner = data.owner;

    const kind = 7;

    // Now you can use the received data to perform any desired actions
    console.log("Received Data - postId:", postId);
    console.log("Received Data - Path:", path);
    console.log("Received Data - Timestamp:", timestamp);
    console.log("Received Data - UID:", uid);
    console.log("Received Data - ID:", id);
    console.log("Received Data - Owner:", owner);
    console.log("Received Data - commentId:", id);
    // Check if a notification with the same kind and post exists

    const existingNotificationQuerySnapshot = await admin
        .firestore()
        .collection('notifications')
        .doc(owner)
        .collection('user-notifications')
        .where('contentId', '==', postId)
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
            contentId: postId,
            commentId: id,
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
        // Update the notification document with the generated ID
        await notificationRef.update({ id: notificationId });
    } else {
        // Update the existing notification document
        const existingNotificationDocRef = existingNotificationQuerySnapshot.docs[0].ref;
        const existingNotificationData = existingNotificationQuerySnapshot.docs[0].data();

        await existingNotificationDocRef.update(
            {
                timestamp: timestamp,
                uid: uid,
            }
        );
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
    const caseLikesRef = admin.firestore().collection(`posts/${contentId}/post-likes`);
    const caseLikesSnapshot = await caseLikesRef.get();
    const updatedLikeCaseCount = caseLikesSnapshot.size;

    console.log('count:', updatedLikeCaseCount);

    title = `Liked by ${firstName} ${lastName}:`;

    if (updatedLikeCaseCount === 1) {

        title = `Liked by ${firstName} ${lastName}:`;

        switch (code) {
        case "es":
            title = `Le gusta a ${firstName} ${lastName}:`;
            break;
        
        case "ca":
            title = `Agrada a ${firstName} ${lastName}_`;
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

const functions = require('firebase-functions');
const admin = require('firebase-admin');

const db = admin.firestore();


exports.addNotificationOnPostLike = functions.firestore.document('posts/{postId}/post-likes/{userId}').onCreate(async (snapshot, context) => {
    const postId = context.params.postId;
    const userId = context.params.userId

    // Get the uid from the postId document. This uid corresponds to the owner of the post and will also be the notification target uid.
    const postSnapshot = await admin.firestore().collection('posts').doc(postId).get();
    const uid = postSnapshot.data().uid;

    const content = postSnapshot.data().post;
    const postTimestamp = postSnapshot.data().timestamp;

    const kind = 0;

    if (userId == uid) {
        // Like from owner of the post
        return;
    }

    // Check if a notification with the same contentId and kind exists
    const existingNotificationQuerySnapshot = await admin
        .firestore()
        .collection('notifications')
        .doc(uid)
        .collection('user-notifications')
        .where('contentId', '==', postId)
        .where('kind', '==', kind)
        .get();

    if (existingNotificationQuerySnapshot.empty) {
        const timestamp = admin.firestore.Timestamp.now();
        // Create a new notification document
        const notificationData = {
            contentId: postId,
            kind: kind,
            timestamp: timestamp,
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
        console.log('Post like notification added to user:', uid);

        console.log('post timestamp:', postTimestamp.seconds);
        console.log('notification timestamp:', timestamp.seconds);

        const timeDifferenceInSeconds = timestamp.seconds - postTimestamp.seconds
        if (timeDifferenceInSeconds >= 60) {
            await notificationRef.update({ notified: notificationData.timestamp });
            await sendNotification(kind, uid, userId, notificationId, content, postId)
        }
    } else {
        // Update the existing notification document
        const existingNotificationDocRef = existingNotificationQuerySnapshot.docs[0].ref;
        const existingNotificationData = existingNotificationQuerySnapshot.docs[0].data();

        const notificationId = existingNotificationData.notificationId;
        const timestamp = admin.firestore.FieldValue.serverTimestamp()

        if (!existingNotificationData.notified) {
            // Perform your specific action here
            console.log('User received likes within the first 60 seconds of the post');
            await existingNotificationDocRef.update(
                {
                    timestamp: timestamp,
                    notified: timestamp,
                    uid: userId,
                }
            );
            await sendNotification(kind, uid, userId, notificationId, content, postId)

        } else {
            await existingNotificationDocRef.update(
                {
                    timestamp: admin.firestore.FieldValue.serverTimestamp(),
                    uid: userId,
                }
            );
        }

        console.log('Post like notification updated:', uid);
    }
});





exports.addNotificationOnPostComment = functions.firestore.document('posts/{postId}/comments/{commentId}').onCreate(async (snapshot, context) => {
    const postId = context.params.postId;
    const commentId = context.params.commentId;
    // Owner of the comment
    const userId = snapshot.data().uid;

    const postSnapshot = await admin.firestore().collection('posts').doc(postId).get();
    // Owner of the post
    const ownerUid = postSnapshot.data().uid;
    const content = postSnapshot.data().post;
    const postTimestamp = postSnapshot.data().timestamp;

    const kind = 3;


    if (userId == ownerUid) {
        // Like from owner of the post
        return;
    }


    // Check if a notification with the same contentId and kind exists
    const existingNotificationQuerySnapshot = await admin
        .firestore()
        .collection('notifications')
        .doc(ownerUid)
        .collection('user-notifications')
        .where('contentId', '==', postId)
        .where('kind', '==', kind)
        .get();


    if (existingNotificationQuerySnapshot.empty) {
        const timestamp = admin.firestore.Timestamp.now();
        // Create a new notification document
        const notificationData = {
            commentId: commentId,
            contentId: postId,
            kind: kind,
            timestamp: timestamp,
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
        console.log('Post comment notification added to user:', ownerUid);

        const timeDifferenceInSeconds = timestamp.seconds - postTimestamp.seconds
        if (timeDifferenceInSeconds >= 60) {
            await notificationRef.update({ notified: notificationData.timestamp });
            await sendNotification(kind, ownerUid, userId, notificationId, content, postId)
        }
    } else {
        // Update the existing notification document
        const existingNotificationDocRef = existingNotificationQuerySnapshot.docs[0].ref;
        const existingNotificationData = existingNotificationQuerySnapshot.docs[0].data();

        const notificationId = existingNotificationData.notificationId;
        const timestamp = admin.firestore.FieldValue.serverTimestamp()

        if (!existingNotificationData.notified) {
            // Perform your specific action here
            console.log('User received likes within the first 60 seconds of the post');
            await existingNotificationDocRef.update(
                {
                    timestamp: timestamp,
                    notified: timestamp,
                    uid: userId,
                }
            );
            await sendNotification(kind, ownerUid, userId, notificationId, content, postId)

        } else {
            await existingNotificationDocRef.update(
                {
                    timestamp: admin.firestore.FieldValue.serverTimestamp(),
                    uid: userId,
                }
            );
        }

        console.log('Post comment notification updated:', ownerUid);
    }
});


exports.addNotificationOnNewFollower = functions.firestore.document('followers/{userId}/user-followers/{followerId}').onCreate(async (snapshot, context) => {
    const followerId = context.params.followerId;
    const userId = context.params.userId;

    const kind = 2;

    // Check if a notification with the same contentId and kind exists
    const existingNotificationQuerySnapshot = await admin
        .firestore()
        .collection('notifications')
        .doc(userId)
        .collection('user-notifications')
        .where('kind', '==', kind)
        .get();

    if (existingNotificationQuerySnapshot.empty) {
        const timestamp = admin.firestore.Timestamp.now();
        // Create a new notification document
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
        // Update the notification document with the generated ID
        await notificationRef.update({ id: notificationId });
        console.log('following notification added to user:', userId);

        await notificationRef.update({ notified: notificationData.timestamp });
        await sendNotification(kind, userId, userId, notificationId, "", "")
    } else {
        const existingNotificationDocRef = existingNotificationQuerySnapshot.docs[0].ref;
        const existingNotificationData = existingNotificationQuerySnapshot.docs[0].data();

        const notificationId = existingNotificationData.notificationId;
        const lastNotifiedTimestamp = existingNotificationData.timestamp;
        const timestamp = admin.firestore.Timestamp.now()

        const timeDifferenceInSeconds = timestamp.seconds - lastNotifiedTimestamp.seconds
        if (timeDifferenceInSeconds >= 60 * 60 * 2) {
            await existingNotificationDocRef.update(
                {
                    timestamp: timestamp,
                    notified: timestamp,
                    uid: followerId,
                }
            );

            await sendNotification(kind, userId, followerId, notificationId, "", "")
        } else {
            await existingNotificationDocRef.update(
                {
                    timestamp: timestamp,
                    uid: followerId,
                }
            );
        }
    }
    console.log('follow notification updated:', userId);
});


exports.addNotificationOnCaseLike = functions.firestore.document('cases/{caseId}/case-likes/{userId}').onCreate(async (snapshot, context) => {
    const caseId = context.params.caseId;
    const userId = context.params.userId

    // Get the ownerUid from the postId document
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
        const timestamp = admin.firestore.Timestamp.now();
        // Create a new notification document
        const notificationData = {
            contentId: caseId,
            kind: kind,
            timestamp: timestamp,
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

        const timeDifferenceInSeconds = timestamp.seconds - postTimestamp.seconds
        if (timeDifferenceInSeconds >= 60) {
            await notificationRef.update({ notified: notificationData.timestamp });
            await sendNotification(kind, ownerUid, userId, notificationId, content, caseId)
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
                    timestamp: timestamp,
                    notified: timestamp,
                    uid: userId,
                }
            );
            await sendNotification(kind, ownerUid, userId, notificationId, content, caseId)

        } else {
            await existingNotificationDocRef.update(
                {
                    timestamp: admin.firestore.FieldValue.serverTimestamp(),
                    uid: userId,
                }
            );
        }

        console.log('Case like notification updated:', ownerUid);
    }
});


exports.addNotificationOnCaseComment = functions.firestore.document('cases/{caseId}/comments/{commentId}').onCreate(async (snapshot, context) => {
    const caseId = context.params.caseId;
    const commentId = context.params.commentId;
    // Owner of the comment
    const userId = snapshot.data().uid;

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
        const timestamp = admin.firestore.Timestamp.now();
        // Create a new notification document
        const notificationData = {
            commentId: commentId,
            contentId: caseId,
            kind: kind,
            timestamp: timestamp,
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
        console.log('Post comment notification added to user:', ownerUid);

        const timeDifferenceInSeconds = timestamp.seconds - postTimestamp.seconds
        if (timeDifferenceInSeconds >= 60) {
            await notificationRef.update({ notified: notificationData.timestamp });
            await sendNotification(kind, ownerUid, userId, notificationId, content, caseId)
        }
    } else {
        // Update the existing notification document
        const existingNotificationDocRef = existingNotificationQuerySnapshot.docs[0].ref;
        const existingNotificationData = existingNotificationQuerySnapshot.docs[0].data();

        const notificationId = existingNotificationData.notificationId;
        const timestamp = admin.firestore.FieldValue.serverTimestamp()

        if (!existingNotificationData.notified) {
            // Perform your specific action here
            console.log('User received likes within the first 60 seconds of the post');
            await existingNotificationDocRef.update(
                {
                    timestamp: timestamp,
                    notified: timestamp,
                    uid: userId,
                }
            );
            await sendNotification(kind, ownerUid, userId, notificationId, content, postId)

        } else {
            await existingNotificationDocRef.update(
                {
                    timestamp: admin.firestore.FieldValue.serverTimestamp(),
                    uid: userId,
                }
            );
        }
        console.log('Post comment notification updated:', ownerUid);
    }
});










exports.addNotificationOnCaseRevision = functions.firestore.document('cases/{caseId}/case-revisions/{revisionId}').onCreate(async (snapshot, context) => {
    const caseId = context.params.caseId;
    const revisionId = context.params.revisionId;

    const revisionData = snapshot.data();

    const revisionKind = revisionData.kind
    const revisionTitle = revisionData.title

    const caseRef = admin.firestore().doc(`cases/${caseId}`);

    // Update the revision kind
    await caseRef.update(
        {
            revision: revisionKind
        }
    );

    console.log('Case revision updated:');
});


exports.sendNotificationOnNewMessage = functions.database.ref('conversations/{conversationId}/messages/{messageId}').onCreate(async (snapshot, context) => {
    // Get the conversation ID and data
    const conversationId = context.params.conversationId;
    const messageId = context.params.messageId;
    const messageData = snapshot.val();

    const sentDate = messageData.date;
    const senderId = messageData.senderId;
    const message = messageData.text;

    const userIds = conversationId.split('_');

    const userId1 = userIds[0];
    const userId2 = userIds[1];

    const receiverId = (senderId === userId1) ? userId2 : userId1;


    // Check notification preferences of receiverId
    const preferencesRef = db.collection('notifications').doc(receiverId);
    const preferencesSnapshot = await preferencesRef.get();
    const preferences = preferencesSnapshot.data();

    if (!preferences.enabled) {
        // Stop execution if notifications are disabled for the user
        console.log('Notifications disabled', ownerUid);
        return;
    }

    if (!preferences.message) {
        console.log('Message Notifications Disabled', ownerUid);
        return;
    }

    const senderDoc = await admin.firestore().collection('users').doc(senderId).get();
    const senderSnapshot = senderDoc.data();

    const profileImageUrl = senderSnapshot.profileImageUrl;
    const firstName = senderSnapshot.firstName;
    const lastName = senderSnapshot.lastName;


    const tokenSnapshot = await admin.database().ref(`/tokens/${receiverId}`).once('value');
    const tokenData = tokenSnapshot.val();

    // Create the notification payload
    const notificationPayload = {
        notification: {
            title: `${firstName} ${lastName}`,
            body: message
        },
        token: tokenData,
    };

    // Send the notification using the Firebase Admin SDK
    await admin.messaging().send(notificationPayload);
});

async function sendNotification(kind, ownerUid, userId, notificationId, content, contentId) {

    const preferencesRef = db.collection('notifications').doc(ownerUid);
    const preferencesSnapshot = await preferencesRef.get();
    const preferences = preferencesSnapshot.data();

    if (!preferences.enabled) {
        // Stop execution if notifications are disabled for the user
        console.log('Notifications disabled', ownerUid);
        return;
    }

    switch (kind) {
        case 0:
            // Post like
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
            break;
        case 1:
            // Case like
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
            break;
        case 2:
            if (!preferences.follower) {
                console.log('user dont to receive following notifications:', ownerUid);
                return;
            }
            break;
        case 3:
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
                console.log('User is beeing followed. Notification will be sent:', ownerUid);
            } else {
                console.log('user wants to receive notifications from everyone:', ownerUid);
            }

            break;
        case 4:
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
                console.log('User is beeing followed. Notification will be sent:', ownerUid);
            } else {
                console.log('user wants to receive notifications from everyone:', ownerUid);
            }
            break;
        case 5:
        // ... existing code ...
    }

    // Here before fetching user checking that if only wants to get notified by users that folllowrers, updat eit
    console.log('user that is sendign notification:', userId);
    const userRef = admin.firestore().collection('users').doc(userId);
    const userSnapshot = await userRef.get();
    const user = userSnapshot.data();

    const firstName = user.firstName;
    const lastName = user.lastName;


    let message = "";
    let title = "";

    const tokenSnapshot = await admin.database().ref(`/tokens/${ownerUid}`).once('value');
    const tokenData = tokenSnapshot.val();

    switch (kind) {
        case 0:
            // Post Like
            functions.logger.log('Retrieving post likes');
            const postLikesRef = admin.firestore().collection(`posts/${contentId}/post-likes`);
            const postLikesSnapshot = await postLikesRef.get();
            const updatedLikePostCount = postLikesSnapshot.size;

            if (updatedLikePostCount === 1) {
                title = `Liked by ${firstName} ${lastName}:`;
            } else if (updatedLikePostCount === 2) {
                title = `Liked by ${firstName} ${lastName} and another:`;
            } else if (updatedLikePostCount > 1) {
                const additionalPostLikes = updatedLikePostCount - 1;
                title = `Liked by ${firstName} ${lastName} and ${additionalPostLikes} others:`;
            }
            message = content
            break;
        case 1:
            // Case Like
            functions.logger.log('Retrieving case likes');
            const caseLikesRef = admin.firestore().collection(`cases/${contentId}/case-likes`);
            const caseLikesSnapshot = await caseLikesRef.get();
            const updatedLikeCaseCount = caseLikesSnapshot.size;

            if (updatedLikeCaseCount === 1) {
                title = `Liked by ${firstName} ${lastName}:`;
            } else if (updatedLikeCaseCount === 2) {
                title = `Liked by ${firstName} ${lastName} and more:`;
            } else if (updatedLikeCaseCount > 2) {
                const additionalCaseLikes = updatedLikeCaseCount - 1;
                title = `Liked by ${firstName} ${lastName} and ${additionalCaseLikes} others:`;
            }
            message = content
            break;
        case 2:
            // ... existing code ...
            title = `${firstName} ${lastName} is following you`;
            break;
        case 3:
            // Post Reply
            const postCommentRef = admin.firestore().collection(`posts/${contentId}/comments`);
            const postCommentSnapshot = await postCommentRef.get();
            const updatedCommentPostCount = postCommentSnapshot.size;

            if (updatedCommentPostCount === 1) {
                title = `${firstName} ${lastName} replied:`;
            } else if (updatedCommentPostCount > 1) {
                title = `${firstName} ${lastName} and more replied:`;
            }

            message = content
            break;
        case 4:
            // Case Reply
            const caseCommentRef = admin.firestore().collection(`cases/${contentId}/comments`);
            const caseCommentSnapshot = await caseCommentRef.get();
            const updatedCommentCaseCount = caseCommentSnapshot.size;

            if (updatedCommentCaseCount === 1) {
                title = `${firstName} ${lastName} replied:`;
            } else if (updatedCommentCaseCount > 1) {
                title = `${firstName} ${lastName} and more replied:`;
            }

            message = content
            break;
            break;
        case 5:
        // ... existing code ...
    }

    // Send the notification
    const payload = {
        notification: {
            title: title,
            body: message
        }
    };

    await admin.messaging().sendToDevice(tokenData, payload);
    functions.logger.log('Notifications sent');
}


// Function to remove a feed reference for a specific post
async function removeNotificationsforPost(postId, userId) {
    // Delete notifications for the post
    const notificationsRef = admin.firestore().collection(`notifications/${userId}/user-notifications`);
    const querySnapshot = await notificationsRef.where('contentId', '==', postId).get();
    
    const deletePromises = [];
        querySnapshot.forEach((doc) => {
            const deletePromise = doc.ref.delete();
            deletePromises.push(deletePromise);
        });

        await Promise.all(deletePromises);
};

module.exports = {
    removeNotificationsforPost
};

// Function to remove a feed reference for a specific case
async function removeNotificationsForCase(caseId, userId) {
    const notificationsRef = admin.firestore().collection(`notifications/${userId}/user-notifications`);
    const querySnapshot = await notificationsRef.where('contentId', '==', caseId).get();

    const deletePromises = [];
        querySnapshot.forEach((doc) => {
            const deletePromise = doc.ref.delete();
            deletePromises.push(deletePromise);
        });

        await Promise.all(deletePromises);
};


module.exports = {
    removeNotificationsForCase
};

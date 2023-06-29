const functions = require('firebase-functions');
const admin = require('firebase-admin');

const db = admin.firestore();


exports.addNotificationOnLike = functions.firestore.document('posts/{postId}/post-likes/{userId}').onCreate(async (snapshot, context) => {
    const postId = context.params.postId;
    const userId = context.params.userId

    // Get the ownerUid from the postId document
    const postSnapshot = await admin.firestore().collection('posts').doc(postId).get();
    const ownerUid = postSnapshot.data().ownerUid;

    const content = postSnapshot.data().post;
    const postTimestamp = postSnapshot.data().timestamp;

    const kind = 0;

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
        console.log('Post like notification added to user:', ownerUid);

        console.log('post timestamp:', postTimestamp.seconds);
        console.log('notification timestamp:', timestamp.seconds);

        const timeDifferenceInSeconds = timestamp.seconds - postTimestamp.seconds
        if (timeDifferenceInSeconds >= 30) {
            await notificationRef.update({ notified: notificationData.timestamp });
            await sendNotification(kind, ownerUid, userId, notificationId, content)
        }
    } else {
        // Update the existing notification document
        const existingNotificationDocRef = existingNotificationQuerySnapshot.docs[0].ref;
        const existingNotificationData = existingNotificationQuerySnapshot.docs[0].data();

        const notificationId = existingNotificationData.notificationId;
        const timestamp = admin.firestore.FieldValue.serverTimestamp()

        if (!existingNotificationData.notified) {
            // Perform your specific action here
            console.log('User received likes within the first 30 seconds of the post');
            await existingNotificationDocRef.update(
                {
                    timestamp: timestamp,
                    notified: timestamp,
                    uid: userId,
                }
            );
            await sendNotification(kind, ownerUid, userId, notificationId, content)

        } else {
            await existingNotificationDocRef.update(
                {
                    timestamp: admin.firestore.FieldValue.serverTimestamp(),
                    uid: userId,
                }
            );
        }

        console.log('Post like notification updated:', ownerUid);
    }
});

async function sendNotification(kind, ownerUid, userId, notificationId, content) {

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
            if (!preferences.like.value) {
                console.log('user dont to receive like notifications:', ownerUid);
                return;
            }

            console.log('user wants to receive like notifications:', ownerUid);
            // User can have preferences enabled but not like enabled. like contains 2 fields inside, value which is true or false and target. 0 means from network and 1 from anyone.
            // so first check if the field like with the nested field value is true because if not user doesnt want to receive like notifications and you can return
            break;
        case 1:
            // ... existing code ...
            break;
        case 2:
            // ... existing code ...
            break;
        case 3:
            // ... existing code ...
            break;
        case 4:
            // ... existing code ...
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

    const tokenSnapshot = await admin.database().ref(`/tokens/${userId}`).once('value');
    const tokenData = tokenSnapshot.val();




    switch (kind) {
        case 0:
            title = `Liked by ${firstName} ${lastName}:`
            message = content
            // ... existing code ...
            break;
        case 1:
            // ... existing code ...
            break;
        case 2:
            // ... existing code ...
            break;
        case 3:
            // ... existing code ...
            break;
        case 4:
            // ... existing code ...
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

/*
// Cloud Function that sends a notification to the 'userId' when a notification document is created
exports.sendNotification = functions.firestore.document('notifications/{userId}/user-notifications/{notificationId}').onCreate(async (snap, context) => {
    const userId = context.params.userId;
    const notificationId = context.params.notificationId;
    const notificationData = snap.data();


    const userRef = db.collection('users').doc(notificationData.uid);
    const userSnapshot = await userRef.get();
    const user = userSnapshot.data();

    const preferencesRef = db.collection('notifications').doc(userId);
    const preferencesSnapshot = await preferencesRef.get();
    const preferences = preferencesSnapshot.data();

    if (!preferences.enabled) {
        // Stop execution if notifications are disabled for the user
        return;
    }

    const firstName = user.firstName;
    const lastName = user.lastName;

    const kind = notificationData["kind"];
    const commentText = notificationData.comment || '';

    let message = "";
    let delayTime = 1 * 60 * 1000; // Default delay time in milliseconds


    switch (kind) {
        case 0:
            if (preferences.like) {
                message = `${firstName} ${lastName} liked your post.`
                delayTime = 15 * 1000; // Delay time for post like notification
            } else {
                return;
            }
            break;
        case 1:
            if (preferences.like) {
                message = `${firstName} ${lastName} liked your case.`
            } else {
                return;
            }
            break;
        case 2:
            if (preferences.follower) {
                message = `${firstName} is now following you.`
            } else {
                return;
            }
            break;
        case 3:
            if (preferences.reply) {
                message = `${firstName} ${lastName} commented on your post.`
            } else {
                return;
            }
            break;
        case 4:
            if (preferences.reply) {
                message = `${firstName} ${lastName} commented on your case.`
            } else {
                return
            }
            break;
        case 5:
            if (preferences.trackCase) {
                message = `${firstName} ${lastName} whose case you saved, added a new update.`
            } else {
                return;
            }
    }

    const tokenSnapshot = await admin.database().ref(`/tokens/${userId}`).once('value');
    const tokenData = tokenSnapshot.val();

    try {
        // Wait for 2 minutes
        functions.logger.log('Notifications function started');

        functions.logger.log('Waiting for 2 minutes');
        //await delay(0.5 * 60 * 1000);
        functions.logger.log('first minute done');
        // Get the updated like count for the post
        const postId = notificationData.contentId;
        functions.logger.log('Retrieving post likes');
        const postLikesRef = admin.firestore().collection(`posts/${postId}/post-likes`);
        const postLikesSnapshot = await postLikesRef.get();
        const updatedLikeCount = postLikesSnapshot.size;

        if (updatedLikeCount > 0) {
            // Build the message based on the updated like count
            if (updatedLikeCount === 1) {
                message = `${firstName} ${lastName} liked your post.`;
            } else if (updatedLikeCount === 2) {
                message = `${firstName} ${lastName} and others liked your post.`;
            } else {
                message = `${firstName} ${lastName} and ${updatedLikeCount - 1} others liked your post.`;
            }

            // Send the notification
            const payload = {
                notification: {
                    body: message
                }
            };

            await admin.messaging().sendToDevice(tokenData, payload);

            if (updatedLikeCount > 1) {
                // Wait for 30 minutes before sending additional notifications
                await delay(1 * 60 * 1000);
                functions.logger.log('Additional timer set');

                // Get the updated like count again
                const postLikesSnapshotAfterDelay = await postLikesRef.get();
                const updatedLikeCountAfterDelay = postLikesSnapshotAfterDelay.size;

                if (updatedLikeCountAfterDelay > updatedLikeCount) {
                    // Send additional notification with the updated like count
                    const additionalMessage = `${updatedLikeCountAfterDelay - updatedLikeCount} others liked your post.`;
                    const additionalPayload = {
                        notification: {
                            body: additionalMessage
                        }
                    };

                    await admin.messaging().sendToDevice(tokenData, additionalPayload);
                }
            }
        }

        functions.logger.log('Notifications sent');
    } catch (error) {
        functions.logger.error('Error sending notifications:', error);
        console.error(error); // Print the error stack trace
    }
});


what do you think i've commed up with a solution. when user sends notification, we check the time the post was created. if the post was created like 1 second ago and the notification was sent at the same time, means user potentially has a high volume of likes we don't send the notification. if it was created more than x minutes means low volume so we send the notification for example yes. after that we send notification with likes and we need to put a value so thi snotification indicating the traffic so the next notification will be sent after x time + x times the number of likes already added. what do you think? 
exactly and if a user scales very fast and my calculations set that at 100 and my alfa value is 10 receives but next 5 seconds receive 2000, the threshold is passed but to avoid sending anothe rnotification in 10 seconds we can set that the notification needs to be at least 30 minutes later 
ok so it will be needed to store not only the updated timestmap of notification but also the last t ime it was delivered to the user
*/


// Helper function to delay execution

function delay(ms) {
    return new Promise((resolve) => {
        setTimeout(resolve, ms);
    });
}

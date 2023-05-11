const functions = require('firebase-functions');
const admin = require('firebase-admin');
const cors = require('cors')({ origin: true });
var config = require('./config');
admin.initializeApp();

const { object } = require('firebase-functions/v1/storage');
const { firestore } = require('firebase-admin');

const db = admin.firestore();

const APP_NAME = 'EVIDENS';

// Cloud Function that listens for document creations in the 'posts' collection and performs the necessary actions to update the 'user-home-feed' collection of every follower.
exports.updateUserHomeFeed = functions.firestore.document('posts/{postId}').onCreate(async (snapshot, context) => {
  const postId = context.params.postId;
  const post = snapshot.data();

  // Get the followers of the post creator
  const postCreatorId = post.ownerUid;
  const followersRef = db.collection('followers').doc(postCreatorId).collection('user-followers');
  const followersSnapshot = await followersRef.get();
  
  const followerIds = followersSnapshot.docs.map(doc => doc.id);

  followerIds.push(postCreatorId);

  // Update the user-home-feed collection for each follower
  const batch = db.batch();

  const timestamp = admin.firestore.FieldValue.serverTimestamp();

  const feedData = {
  timestamp: timestamp
  };

  // Loop through each follower document in the followersSnapshot
  followerIds.forEach(followerId => {
    const feedRef = db.collection('users').doc(followerId).collection('user-home-feed').doc(postId);
    batch.set(feedRef, feedData)
  })

  // Commit the batch write operation
  await batch.commit();
})


// Cloud Function that listens for document creations in the 'followers/{userId}/user-followers' collection and performs the necessary actions to update the 'user-home-feed' collection
exports.updateUserHomeFeedOnFollow = functions.firestore.document('followers/{userId}/user-followers/{followerId}').onCreate(async (snapshot, context) => {
  const followerId = context.params.followerId;
  const userId = context.params.userId;
  //;('users/{userId}/profile/posts')
  const postsRef = admin.database().ref(`users/${userId}/profile/posts`);
  const followerHomeFeedRef = admin.firestore().collection('users').doc(followerId).collection('user-home-feed');

  const postSnapshot = await postsRef.once('value');
  const postsData = postSnapshot.val();

  if (postsData) {
    const batch = admin.firestore().batch();

    Object.keys(postsData).forEach((postId) => {
      const timestamp = postsData[postId].timestamp;

      const feedRef = followerHomeFeedRef.doc(postId);
      batch.set(feedRef, { timestamp });
    });

    await batch.commit();
  }
})


// Cloud Function that listens for document deletions in the 'followers/{userId}/user-followers' collection and performs the necessary actions to update the 'user-home-feed' collection
exports.updateUserHomeFeedOnUnfollow = functions.firestore.document('followers/{userId}/user-followers/{followerId}').onDelete(async (snapshot, context) => {
  const followerId = context.params.followerId;
  const userId = context.params.userId;

  const postsRef = admin.database().ref(`users/${userId}/profile/posts`);
  const followerHomeFeedRef = admin.firestore().collection('users').doc(followerId).collection('user-home-feed');

  const postSnapshot = await postsRef.once('value');
  const postsData = postSnapshot.val();

  if (postsData) {
    const batch = admin.firestore().batch();

    Object.keys(postsData).forEach((postId) => {
      const feedRef = followerHomeFeedRef.doc(postId);
      batch.delete(feedRef);
    });

    await batch.commit();
  }
})


// Cloud Function that sends a notification to the 'userId' when a notification document is created

exports.sendNotification = functions.firestore.document('notifications/{userId}/user-notifications/{notificationId}').onCreate(async (snap, context) => {
  const userId = context.params.userId;
  const notificationId = context.params.notificationId;
  const notificationData = snap.data();

  const userRef = db.collection('users').doc(notificationData.uid);
  const userSnapshot = await userRef.get();
  const user = userSnapshot.data();

  const firstName = user.firstName;
  const lastName = user.lastName;

  const notificationType = notificationData["type"];
  const commentText = notificationData.comment || '';

  let messageTitle;

  switch (notificationType) {
    case 0:
      messageTitle = `${firstName} ${lastName} liked your post.`
      break;
    case 1:
      messageTitle = `${firstName} ${lastName} liked your case.`
      break;
    case 2:
      messageTitle = `${firstName} is now following you.`
      break;
    case 3:
      commentText = notificationData["comment"]
      messageTitle = `${firstName} ${lastName} commented on your post: ${commentText}.`
      break;

    case 4:
      commentText = notificationData["comment"]
      messageTitle = `${firstName} ${lastName} commented on your case: ${commentText}.`
      break;
  }

  const tokenSnapshot = await admin.database().ref(`/tokens/${userId}`).once('value');
  const tokenData = tokenSnapshot.val();

  const payload = {
    notification: {
      body: messageTitle
    }
  };


  try {
    const response = await admin.messaging().sendToDevice(tokenData, payload);
    functions.logger.log('Notification sent:', response);
  } catch (error) {
    functions.logger.error('Error sending notification:', error);
  }
  });

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




// Send notification NOT FINISHED
exports.sendNotification = functions.firestore.document('notifications/{userId}/user-notifications/{notificationId}').onCreate(async (snap, context) => {
  const userId = context.params.userId;
  const notificationId = context.params.notificationId;

  const notificationData = snap.data();
  const firstName = notificationData.firstName;
  const lastName = notificationData.lastName;

  const notificationType = notificationData["type"];

  let messageTitle;
  let commentText;

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

  const token = admin.database().ref(`/tokens/${userId}`).once('value');

  //const tokenSnapshot = await Promise(token)

  const tokenData = (await token).val();

  //let tokenData;
  //tokenData = Object.keys(tokenSnapshot.val())

  //tokenData = Promise.token

  functions.logger.log('We have a new notification for user:', userId, 'with notificationId:', notificationId, 'with type:', notificationType);

  const payload = {
    notification: {
      body: messageTitle
    }
  };

  await admin.messaging().sendToDevice(tokenData, payload)
    .then(function (response) {
      return 'Notification sent: ', response;
    })
    .then(function (error) {
      throw ('Notification sent: ', error);
    })

})


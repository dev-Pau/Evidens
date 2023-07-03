const functions = require('firebase-functions');
const admin = require('firebase-admin');
const cors = require('cors')({ origin: true });
var config = require('./config');
admin.initializeApp();

const { object } = require('firebase-functions/v1/storage');
const { firestore } = require('firebase-admin');

const { sendNotification, addNotificationOnPostLike, addNotificationOnCaseLike, addNotificationOnCaseRevision, addNotificationOnPostComment, addNotificationOnCaseComment, addNotificationOnNewFollower, sendNotificationOnNewMessage } = require('./notifications');

const db = admin.firestore();

const APP_NAME = 'EVIDENS';

exports.sendNotification = sendNotification;
exports.addNotificationOnPostLike = addNotificationOnPostLike;
exports.addNotificationOnCaseLike = addNotificationOnCaseLike;
exports.addNotificationOnCaseRevision = addNotificationOnCaseRevision;
exports.addNotificationOnPostComment = addNotificationOnPostComment;
exports.addNotificationOnCaseComment = addNotificationOnCaseComment;
exports.addNotificationOnNewFollower = addNotificationOnNewFollower;
exports.sendNotificationOnNewMessage = sendNotificationOnNewMessage;

exports.onUserCreate = functions.firestore.document('users/{userId}').onCreate(async (snapshot, context) => {
    const userId = context.params.userId;

    const preferencesData = {
      enabled: false,
      reply: {
        value: true,
        replyTarget: 0, // Update with your desired default value for replyTarget
      },
      like: {
        value: true,
        likeTarget: 0, // Update with your desired default value for likeTarget
      },
      follower: true,
      message: false,
      trackCase: false
    };

    try {
      const preferencesRef = admin.firestore().collection('notifications').doc(userId);
      await preferencesRef.set(preferencesData);
    } catch (error) {
      console.error('Error creating notification preferences:', error);
    }
  });

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


// Cloud Function that adds the first message to both users when a new conversation is created
exports.onConversationCreate = functions.database.ref('/conversations/{conversationId}').onCreate((snapshot, context) => {
  // Get the conversation ID and data
  const conversationId = context.params.conversationId;
  const conversationData = snapshot.val();

  // Extract user IDs from conversation ID
  const userIds = conversationId.split('_');
  const userId1 = userIds[0];
  const userId2 = userIds[1];

  // Get the message ID from the conversation data
  const messageKey = Object.keys(conversationData.messages)[0];
  const date = conversationData.messages[messageKey].date;
  const senderId = conversationData.messages[messageKey].senderId;

  // Set message data for user1
  const messageData1 = {
    userId: userId2,
    latestMessage: messageKey,
    sync: senderId === userId1 ? true : false,
    date: date
  };

  // Set message data for user2
  const messageData2 = {
    userId: userId1,
    latestMessage: messageKey,
    sync: senderId === userId2 ? true : false,
    date: date
  };

  // Add conversation to user1's real-time database
  const user1Ref = admin.database().ref(`users/${userId1}/conversations/${conversationId}`);
  user1Ref.set(messageData1);

  // Add conversation to user2's real-time database
  const user2Ref = admin.database().ref(`users/${userId2}/conversations/${conversationId}`);
  user2Ref.set(messageData2);
});

// Cloud Function that triggers on new messages within existing conversations
exports.onNewMessage = functions.database.ref('conversations/{conversationId}/messages/{messageId}').onCreate((snapshot, context) => {
  // Get the conversation ID and data
  const conversationId = context.params.conversationId;
  const messageId = context.params.messageId;
  const messageData = snapshot.val();
  const sentDate = messageData.date

  // Log the value of sentDate
  functions.logger.log('sentDate:', sentDate);
  
  // Update latestMessage and sync for both users
  const userIds = conversationId.split('_');
  const userId1 = userIds[0];
  const userId2 = userIds[1];

  const user1Ref = admin.database().ref(`users/${userId1}/conversations/${conversationId}`);
  user1Ref.once('value', user1Snapshot => {
    if (user1Snapshot.exists()) {
      // User1 has a reference to the conversation, update the existing data
      const messageData1 = {
        latestMessage: messageId,
        sync: userId1 === messageData.senderId ? true : false
      };
      user1Ref.update(messageData1);
    } else {
      // User1 does not have a reference, create new data
      const messageData1 = {
        userId: userId2,
        latestMessage: messageId,
        sync: messageData.senderId === userId1 ? true : false,
        date: sentDate
      };
      functions.logger.log('User1Ref', messageData1.date);
      user1Ref.set(messageData1);
    }
  });

  // Check if user2 has a reference to the conversation
  const user2Ref = admin.database().ref(`users/${userId2}/conversations/${conversationId}`);
  user2Ref.once('value', user2Snapshot => {
    if (user2Snapshot.exists()) {
      // User2 has a reference to the conversation, update the existing data
      const messageData2 = {
        latestMessage: messageId,
        sync: userId2 === messageData.senderId ? true : false
      };
      user2Ref.update(messageData2);
    } else {
      // User2 does not have a reference, create new data
      const messageData2 = {
        userId: userId1,
        latestMessage: messageId,
        sync: messageData.senderId === userId2 ? true : false,
        date: sentDate
      };
      functions.logger.log('User2Ref', messageData2.date);
      user2Ref.set(messageData2);
    }
  });
});
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const cors = require('cors')({ origin: true });
var config = require('./config');
admin.initializeApp();

const { object } = require('firebase-functions/v1/storage');
const { firestore } = require('firebase-admin');

const { removeBookmarksForPost, removeBookmarksForCase } = require('./bookmarks');
const { removePostFromFeed } = require('./users');
const { removeNotificationsforPost, removeNotificationsForCase } = require('./notifications');

const { addNotificationOnNewConnection } = require('./followers-onCreate');

const { addNotificationOnAcceptConnection } = require('./connections-https');

const { addNotificationOnPostLike, addNotificationOnPostCommentLike, addNotificationOnPostLikeReply } = require('./posts-likes-onCreate');
const { addNotificationOnPostComment, addNotificationOnPostReply } = require('./posts-comments-onCreate');

const { addNotificationOnCaseLike, addNotificationOnCaseCommentLike, addNotificationOnCaseLikeReply } = require('./cases-likes-onCreate');

const { addNotificationOnCaseComment, addNotificationOnCaseReply } = require('./cases-comments-onCreate');

const db = admin.firestore();

const APP_NAME = 'EVIDENS';

exports.addNotificationOnPostLike = addNotificationOnPostLike;
exports.addNotificationOnPostCommentLike = addNotificationOnPostCommentLike;
exports.addNotificationOnPostLikeReply = addNotificationOnPostLikeReply;

exports.addNotificationOnCaseLike = addNotificationOnCaseLike;
exports.addNotificationOnCaseCommentLike = addNotificationOnCaseCommentLike;
exports.addNotificationOnCaseLikeReply = addNotificationOnCaseLikeReply;

exports.addNotificationOnPostReply = addNotificationOnPostReply;
exports.addNotificationOnPostComment = addNotificationOnPostComment;

exports.addNotificationOnCaseReply = addNotificationOnCaseReply;
exports.addNotificationOnCaseComment = addNotificationOnCaseComment;

exports.addNotificationOnNewConnection = addNotificationOnNewConnection;

exports.addNotificationOnAcceptConnection = addNotificationOnAcceptConnection;

exports.onUserCreate = functions.firestore.document('users/{userId}').onCreate(async (snapshot, context) => {
    const userId = context.params.userId;

    const preferencesData = {
      enabled: false,
      reply: {
        value: true,
        replyTarget: 0,
      },
      like: {
        value: true,
        likeTarget: 0,
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

exports.addUserInDatabase = functions.firestore.document('users/{userId}').onCreate(async (snapshot, context) => {
  const userId = context.params.userId;
  const database = admin.database();
  const ref = database.ref("users").child(userId);

  return ref.set({ uid: userId }).catch((error) => {
    console.error("Error writing user to database:", error);
  });
});

// Cloud Function that listens for document creations in the 'posts' collection and performs the necessary actions to update the 'user-home-feed' collection of every follower.
exports.updateUserHomeFeed = functions.firestore.document('posts/{postId}').onCreate(async (snapshot, context) => {
  const postId = context.params.postId;
  const post = snapshot.data();

  // Get the followers of the post creator
  const postCreatorId = post.uid;
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
});


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
});


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
});

exports.onNewConnection = functions.firestore.document('connections/{userId}/user-connections/{connectedUserId}').onCreate(async (snapshot, context) => {
  const userId = context.params.userId;
  const connectedUserId = context.params.connectedUserId;

  let data = snapshot.data();
  let phase = data.phase;
  let timestamp = data.timestamp;

  const timestampData = {
    timestamp: timestamp
  };

  if (phase === 2) {
    // userId is the user that receives the request
    // Update the follower collection
    const followersRef = db.collection(`followers/${userId}/user-followers`);
    await followersRef.doc(connectedUserId).set(timestampData);
    return
  } else if (phase === 1) {
    // userId is the user that sent the connection request
    // Update the following collection
    const followingRef = db.collection(`following/${userId}/user-following`);
    await followingRef.doc(connectedUserId).set(timestampData);
    return
  }
});

exports.onPostChange = functions.firestore.document('posts/{postId}').onUpdate(async (change, context) => {

  const newValue = change.after.data();
  const previousValue = change.before.data();

  if (newValue.visible === 1 && previousValue.visible !== 1) {
    const postId = context.params.postId;
    const userId = newValue.uid;

  // Call the function to remove bookmarks and feed
  await removeBookmarksForPost(postId);
  await removePostFromFeed(postId, userId);
  await removeNotificationsforPost(postId, userId);
  return null;
}

return null;
});

exports.onCaseChange = functions.firestore.document('cases/{caseId}').onUpdate(async (change, context) => {

  const newValue = change.after.data();
  const previousValue = change.before.data();

  if (newValue.visible === 1 && previousValue.visible !== 1) {
    const caseId = context.params.caseId;
    const userId = newValue.uid;

    // Call the function to remove bookmarks and feed
    await removeBookmarksForCase(caseId);
    await removeNotificationsForCase(caseId, userId);
    return null;
  }

  return null;
});


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

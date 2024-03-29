const functions = require('firebase-functions');
const admin = require('firebase-admin');

/*
  ******************************************
  *                                        *
  *                RELEASE                 *
  *            !!  CAUTION !!              *
  *                                        *
  ******************************************
*/

exports.releaseFirestoreCommentsPostsOnCreate = functions.region('europe-west1').firestore.document('posts/{postId}/comments/{commentId}').onCreate(async (snapshot, context) => {
    const postId = context.params.postId;
    const commentId = context.params.commentId;

    const userId = snapshot.data().uid;
    const commentTimestamp = snapshot.data().timestamp;

    const postSnapshot = await admin.firestore().collection('posts').doc(postId).get();

    const ownerUid = postSnapshot.data().uid;
    const content = postSnapshot.data().post;
    const postTimestamp = postSnapshot.data().timestamp;

    const kind = 11;

    if (userId == ownerUid) {
        // Like from owner of the post
        return;
    }

    const notificationData = {
        path: [commentId],
        contentId: postId,
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
    await notificationRef.update({ id: notificationId });
});


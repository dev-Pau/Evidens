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

exports.releaseFirestoreFollowersOnCreate = functions.region('europe-west1').firestore.document('followers/{userId}/user-followers/{followerId}').onCreate(async (snapshot, context) => {
    const followerId = context.params.followerId;
    const userId = context.params.userId;

    const postsRef = admin.database().ref(`users/${userId}/profile/posts`).orderByChild('timestamp').limitToLast(20);
    
    const followerHomeFeedRef = admin.firestore().collection('users').doc(followerId).collection('user-post-network');

    const postSnapshot = await postsRef.once('value');
    const postsData = postSnapshot.val();

    if (postsData) {
        const batch = admin.firestore().batch();

        Object.keys(postsData).forEach((postId) => {

            const timestamp = postsData[postId].timestamp;
            const millisecondsTimestamp = timestamp * 1000;

            const firestoreTimestamp = admin.firestore.Timestamp.fromMillis(millisecondsTimestamp);

            const timestampData = {
                timestamp: firestoreTimestamp,
                uid: userId,
            };

            const feedRef = followerHomeFeedRef.doc(postId);

            batch.set(feedRef, timestampData);
        });

        await batch.commit();
    }
});


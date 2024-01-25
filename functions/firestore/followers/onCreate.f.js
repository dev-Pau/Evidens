const functions = require('firebase-functions');
const admin = require('firebase-admin');
const db = admin.firestore();

exports.firestoreFollowersOnCreate = functions.firestore.document('followers/{userId}/user-followers/{followerId}').onCreate(async (snapshot, context) => {
    const followerId = context.params.followerId;
    const userId = context.params.userId;

    const postsRef = admin.database().ref(`users/${userId}/profile/posts`).orderByChild('timestamp').limitToLast(20);
    
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


const functions = require('firebase-functions');
const admin = require('firebase-admin');
const db = admin.firestore();

/*
  ******************************************
  *                                        *
  *                RELEASE                 *
  *            !!  CAUTION !!              *
  *                                        *
  ******************************************
*/

exports.releaseFirestoreFollowingOnDelete = functions.firestore.document('following/{userId}/user-following/{followingId}').onDelete(async (snapshot, context) => {
    let userId = context.params.userId;
    let followingId = context.params.followingId;

    // Get the posts associated with the followingId user

    let feedRef = admin.firestore().collection('users').doc(userId).collection('user-home-feed').where('uid', '==', followingId);
    const querySnapshot = await feedRef.get();

    // Create batches with a maximum of 500 operations
    const batchSize = 100;
    const batches = [];

    for (let i = 0; i < querySnapshot.size; i += batchSize) {
        const batch = db.batch();
        querySnapshot.docs.slice(i, i + batchSize).forEach(doc => batch.delete(doc.ref));
        batches.push(batch);
    }

    await Promise.all(batches.map(batch => batch.commit()));
}); 

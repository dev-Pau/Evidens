const functions = require('firebase-functions');
const admin = require('firebase-admin');
const db = admin.firestore();
const client = require('../../client-typesense');

exports.firestorePostsOnCreate = functions.firestore.document('posts/{postId}').onCreate(async (snapshot, context) => {

    const postId = context.params.postId;

    const postUserId = snapshot.data().uid;
    const followersRef = db.collection('followers').doc(postUserId).collection('user-followers');
    const followersSnapshot = await followersRef.get();

    const followerIds = followersSnapshot.docs.map(doc => doc.id);
    followerIds.push(postUserId);

    const serverTimestamp = admin.firestore.FieldValue.serverTimestamp();

    const postData = {
        timestamp: serverTimestamp
    };

    const post = snapshot.data().post
    const disciplines = snapshot.data().disciplines

    const currentDate = new Date();
    const currentTimeInMilliseconds = currentDate.getTime();
    const timestamp = Math.round(currentTimeInMilliseconds / 1000);

    const batchSize = 500;

    for (let i = 0; i < followerIds.length; i += batchSize) {
        const batch = db.batch();
    
        const currentBatch = followerIds.slice(i, i + batchSize);
    
        currentBatch.forEach(followerId => {
            const feedRef = db.collection('users').doc(followerId).collection('user-home-feed').doc(postId);
            batch.set(feedRef, postData);
        });
    
        await batch.commit();
    }

    document = { postId, post, disciplines, timestamp }

    client.collections('posts').documents().create(document)

});



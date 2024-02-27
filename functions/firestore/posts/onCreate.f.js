const functions = require('firebase-functions');
const admin = require('firebase-admin');
const db = admin.firestore();
const typesense = require('../../client-typesense');

exports.firestorePostsOnCreate = functions.region('europe-west1').firestore.document('posts/{postId}').onCreate(async (snapshot, context) => {
    const postId = context.params.postId;
    const userId = snapshot.data().uid;

    addPostToFollowers(userId, postId);
    addPostToTypesense(postId, snapshot.data());
});

async function addPostToTypesense(postId, publication) {
    let post = typesense.processText(publication.post);
    let disciplines = publication.disciplines;
    let date = publication.timestamp.toDate();

    const milliseconds = date.getTime();
    const timestamp = Math.round(milliseconds / 1000);

    let document = {
        'id': postId,
        'post': post,
        'disciplines': disciplines,
        'timestamp': timestamp
    };
    
    try {
        await typesense.debugClient.collections('posts').documents().create(document)
        functions.logger.log('Post added to Typesense', postId);
    } catch (error) {
        let documentString = JSON.stringify(document);
        let errorTimestamp = new Date().toUTCString(); // Getting UTC timestamp

        console.error(`Error creating post to Typesense ${postId} at ${errorTimestamp}`, error);
        console.error('Document that caused the error:', documentString);
    }
}

async function addPostToFollowers(userId, postId) {
    const followersRef = db.collection('followers').doc(userId).collection('user-followers');
    const followersSnapshot = await followersRef.get();

    const followerIds = followersSnapshot.docs.map(doc => doc.id);
    followerIds.push(userId);

    const serverTimestamp = admin.firestore.FieldValue.serverTimestamp();

    const postData = {
        timestamp: serverTimestamp,
        uid: userId
    };

    const batchSize = 400;

    for (let i = 0; i < followerIds.length; i += batchSize) {
        const batch = db.batch();
    
        const currentBatch = followerIds.slice(i, i + batchSize);
    
        currentBatch.forEach(followerId => {
            const feedRef = db.collection('users').doc(followerId).collection('user-post-network').doc(postId);
            batch.set(feedRef, postData);
        });
    
        await batch.commit();
    }
}



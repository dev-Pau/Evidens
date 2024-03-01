const functions = require('firebase-functions');
const admin = require('firebase-admin');
const typesense = require('../../client-typesense');

/*
  ******************************************
  *                                        *
  *                RELEASE                 *
  *            !!  CAUTION !!              *
  *                                        *
  ******************************************
*/

exports.releaseFirestorePostsOnUpdate = functions.region('europe-west1').firestore.document('posts/{postId}').onUpdate(async (change, context) => {
    const newValue = change.after.data();
    const previousValue = change.before.data();

    const postId = context.params.postId;
    const userId = newValue.uid;

    const promises = [];

    if (newValue.visible === 1 && previousValue.visible !== 1) {
        // User deletes the post. Remove from Typesense and Profile.
        promises.push(deleteNotificationsforPost(postId, userId));
        promises.push(deletePostFromTypesense(postId));
        promises.push(removeProfileReference(userId, postId));
    } else {
        if (newValue.visible === 0) {
            if (previousValue.visible === 0) {
                // User edits the post, update the data from Typesense
                promises.push(updatePost(postId, change.after.data()));
            } else if (previousValue.visible == 2 || previousValue.visible === 3) {
                // Post gets visible again after being deactivated or banned, it gets added to Typesense and user profile again (if it's already there it's ignored).
                promises.push(addPostToTypesense(postId, change.after.data()));
                promises.push(addProfileReferences(userId, postId, change.after.data()));
            }
        } else if (newValue.visible === 2 && previousValue.visible !== 2) {
            // Post is hidden due to user deactivation. Posts get removed from Typesense but are kept to user profile reference.
            promises.push(deletePostFromTypesense(postId));
        } else if (newValue.visible === 3 && previousValue.visible !== 3) {
            // Post is banned by Evidens. Post is removed from Typesense and from user profile reference.
            promises.push(deletePostFromTypesense(postId));
            promises.push(removeProfileReference(userId, postId));
        }
    }

    // Wait for all promises to resolve
    await Promise.all(promises);

    console.log('All post update operations completed successfully');
});

async function deleteNotificationsforPost(postId, userId) {
    const notificationsRef = admin.firestore().collection(`notifications/${userId}/user-notifications`);
    const querySnapshot = await notificationsRef.where('contentId', '==', postId).get();

    const deletePromises = [];
    querySnapshot.forEach((doc) => {
        const deletePromise = doc.ref.delete();
        deletePromises.push(deletePromise);
    });

    await Promise.all(deletePromises);
};

async function updatePost(postId, publication) {
    const post = typesense.processText(publication.post);

    let document = {
        'id': postId,
        'post': post
    }

    try {
        await typesense.releaseClient.collections('posts').documents(postId).update(document)
        functions.logger.log('Post edited to Typesense', postId);
    } catch (error) {
        let documentString = JSON.stringify(document);
        let errorTimestamp = new Date().toUTCString(); // Getting UTC timestamp

        console.error(`Error updating post from Typesense ${postId} at ${errorTimestamp}`, error);
        console.error('Document that caused the error:', documentString);
    }
}

async function deletePostFromTypesense(postId) {
    functions.logger.log('Deleting post from Typesense', postId);

    try {
        await typesense.releaseClient.collections('posts').documents(postId).delete();
        functions.logger.log('Post removed from Typesense', postId);
    } catch (error) {
        let errorTimestamp = new Date().toUTCString(); // Getting UTC timestamp

        console.error(`Error deleting post from Typesense ${postId} at ${errorTimestamp}`, error);
    }
}

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
        await typesense.releaseClient.collections('posts').documents().create(document)
        functions.logger.log('Post added to Typesense', postId);
    } catch (error) {
        let documentString = JSON.stringify(document);
        let errorTimestamp = new Date().toUTCString(); // Getting UTC timestamp

        console.error(`Error creating post to Typesense ${postId} at ${errorTimestamp}`, error);
        console.error('Document that caused the error:', documentString);
    }
}

async function addProfileReferences(userId, postId, publication) {
   
    const date = publication.timestamp.toDate();
    const timestampInSeconds = Math.floor(date / 1000);

    const timestampSeconds = {
        timestamp: timestampInSeconds
    };

    const userRef = admin.database().ref(`users/${userId}/profile/posts/${postId}`);
    await userRef.set(timestampSeconds);
    functions.logger.log('Post added to profile', postId);
} 

async function removeProfileReference(userId, postId) {
    const userRef = admin.database().ref(`users/${userId}/profile/posts/${postId}`);
    await userRef.remove();
    functions.logger.log('Post removed from profile', postId);
} 
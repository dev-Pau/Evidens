const functions = require('firebase-functions');
const admin = require('firebase-admin');
const typesense = require('../../client-typesense');

/*
----------

enum PostVisibility: Int {

     - Regular: The post is visible and accessible to all users.
     - Deleted: The post has been deleted by the user.
     - Hidden: The post is hidden due to the user's account deactivation or deletion.
     - Disabled: The post has been permanently removed by Evidens.

     case regular, deleted, hidden, disabled
}

----------
*/

exports.firestorePostsOnUpdate = functions.firestore.document('posts/{postId}').onUpdate(async (change, context) => {
    const newValue = change.after.data();
    const previousValue = change.before.data();

    const postId = context.params.postId;
    const userId = newValue.uid;

    if (newValue.visible === 1 && previousValue.visible !== 1) {
        // User deletes the post. Remove from Typesense and Profile.
        deleteNotificationsforPost(postId, userId);
        deletePostFromTypesense(postId);
        removeProfileReference(userId, postId);
    } else {
        if (newValue.visible === 0) {
            if (previousValue.visible === 0) {
                // User edits the post, update the data from Typesense
                updatePost(postId, change.after.data());
            } else if (previousValue.visible == 2 || previousValue.visible === 3) {
                // Post gets visible again after beeing deactivated or banned, it gets added to Typesense and user profile again (if it's already there it's ignored).
                addPostToTypesense(postId, change.after.data())
                addProfileReferences(userId, postId, change.after.data())
            }
        } else if (newValue.visible === 2 && previousValue.visible !== 2) {
            // Post is hidden due to user deactivation. Posts get removed from Typesense but are kept to user profile reference.
            deletePostFromTypesense(postId)
        } else if (newValue.visible === 3 && previousValue.visible !== 3) {
            // Post is banend by Evidens. Post is removed from Typesense and from user profile reference.
            deletePostFromTypesense(postId)
            removeProfileReference(userId, postId)
        }
    }
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
        await typesense.debugClient.collections('posts').documents(postId).update(document)
        functions.logger.log('Post edited to Typesense', postId);
    } catch (error) {
        console.error(`Error adding post to Typesense ${postId}`, error);
    }
}

async function deletePostFromTypesense(postId) {
    try {
        await typesense.debugClient.collections('posts').documents(postId).delete();
        functions.logger.log('Post removed from Typesense', postId);
    } catch (error) {
        console.error(`Error removing post from Typesense ${postId}`, error);
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
        await typesense.debugClient.collections('posts').documents().create(document)
        functions.logger.log('Post added to Typesense', postId);
    } catch (error) {
        console.error(`Error adding post to Typesense ${postId}`, error);
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
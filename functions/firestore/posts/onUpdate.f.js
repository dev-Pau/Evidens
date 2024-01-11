const functions = require('firebase-functions');
const admin = require('firebase-admin');
const db = admin.firestore();
const client = require('../../config');

/*
----------

enum PostVisibility: Int {
    case regular, deleted
}

----------
*/

exports.firestorePostsOnUpdate = functions.firestore.document('posts/{postId}').onUpdate(async (change, context) => {
    const newValue = change.after.data();
    const previousValue = change.before.data();

    // User deletes the post
    if (newValue.visible === 1 && previousValue.visible !== 1) {
        const postId = context.params.postId;
        const userId = newValue.uid;

        deleteNotificationsforPost(postId, userId);
        return client.collections('posts').documents(postId).delete();
    } else {
        // User edits the post
        if (newValue.post !== previousValue.post) {
            const post = newValue.post;
            const id = context.params.postId;
            document = { id, post }
            return client.collections('posts').documents(id).update(document)
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

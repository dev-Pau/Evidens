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

    // User deletes the post
    if (newValue.visible === 1 && previousValue.visible !== 1) {
        const postId = context.params.postId;
        const userId = newValue.uid;

        deleteNotificationsforPost(postId, userId);
        return typesense.debugClient.collections('posts').documents(postId).delete();
    } else {

        if (newValue.visible === 0) {
            if (previousValue.visible === 0) {
                // User edits the post
                console.log("User is editing the post", postId);
                const post = newValue.post;
                const id = context.params.postId;
                
                // TODO: Update Typesense document

                //document = { id, post }
                //return typesense.debugClient.collections('posts').documents(id).update(document)
            } else if (previousValue.visible == 2 || previousValue.visible === 3) {
                // Post was hidden for user account deactivation or post was banned by Evidens
                console.log("Post is visible again after being hidden or disabled", postId);

                // TODO: Add Post To Typee¡sense
            }
        } else if (newValue.visible === 2 && previousValue.visible !== 2) {
            functions.logger.log('Post changes to hidden', postId);

            // TODO: Delete from Typesense
        } else if (newValue.visible === 3 && previousValue.visible !== 3) {
            functions.logger.log('Post changes to disabled', postId);
            // TODO: Delete from Typesense
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

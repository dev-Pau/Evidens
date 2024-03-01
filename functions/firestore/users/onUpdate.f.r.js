const functions = require('firebase-functions');
const admin = require('firebase-admin');
const storage = admin.storage();
var typesense = require('../../client-typesense');



/*
  ******************************************
  *                                        *
  *                RELEASE                 *
  *            !!  CAUTION !!              *
  *                                        *
  ******************************************
*/


exports.releaseFirestoreUsersOnUpdate = functions.region('europe-west1').firestore.document('users/{userId}').onUpdate(async (change, context) => {
    const newUser = change.after.data();
    const previousUser = change.before.data();

    const userId = context.params.userId;

    const promises = [];

    if (newUser.phase === 6 && previousUser.phase !== 6) {

        // If user was previusly deacativated or banned, update his/her posts to visible and add them to Typesense
        if (previousUser.phase === 7 || previousUser.phase === 8) {
            console.log('User account has been activated or unbanned', userId);
            promises.push(updatePostVisibility(0, userId));
        } else {
            console.log('New user verified', userId);
        }

        promises.push(addUserToTypesense(newUser));
    } else if (newUser.phase === 7) {
        // User deactivate his/her account, update his/her posts to hidden and remove them from Typesense;
        console.log('User account has been deactivated', userId);
        promises.push(removeUserFromTypesense(userId));
        promises.push(updatePostVisibility(2, userId));
    } else if (newUser.phase === 8) {
        // User gets banned; remove user from Typesense and update post visibility
        console.log('User account has been banned by Evidens', userId);
        promises.push(removeUserFromTypesense(userId));
        promises.push(updatePostVisibility(2, userId));
    } else if (newUser.phase === 9 && previousUser.phase !== 9) {
        // TODO: Remove all the user information
        console.log('User deleted after 30 days of deactivation', userId);
        promises.push(admin.auth().deleteUser(userId));
    } else if (newUser.phase === 6) {
        // User is; and was verified; Update his/her values from Typesense
        console.log('User updating account details', userId);
        promises.push(updateTypesenseUser(newUser));
    }

    // Wait for all promises to resolve
    await Promise.all(promises);

    console.log('All user operations completed successfully');
});


async function updatePostVisibility(visible, userId) {
    // Update the visibility field of all the regular posts from the user to visible
    const postRef = admin.database().ref(`users/${userId}/profile/posts`);
    const postIds = [];

    try {
        const snapshot = await postRef.once('value');
        const updates = [];

        snapshot.forEach(childSnapshot => {
            const postId = childSnapshot.key;
            const postDocRef = admin.firestore().collection('posts').doc(postId);

            updates.push(postDocRef.update({ visible: visible }));
            postIds.push(postId);
        });

        await Promise.all(updates);
        console.log('All updates successful');
    } catch (error) {
        console.error('Error updating posts:', error);
    }
}

async function addUserToTypesense(user) {
    const userId = user.uid;
    const name = user.firstName + " " + user.lastName;
    const username = user.username;
    const discipline = user.discipline;

    let document = {
        'id': userId,
        'name': name,
        'username': username,
        'discipline': discipline
    };

    try {
        await typesense.releaseClient.collections('users').documents().create(document)
        functions.logger.log('User added to Typesense', userId);
    } catch (error) {
        let documentString = JSON.stringify(document);
        let errorTimestamp = new Date().toUTCString(); // Getting UTC timestamp

        console.error(`Error adding user to Typesense ${userId} at ${errorTimestamp}`, error);
        console.error('Document that caused the error:', documentString);
    }
}

async function removeUserFromTypesense(userId) {
    functions.logger.log('Removing user from Typesense', userId);

    try {
        await typesense.releaseClient.collections('users').documents(userId).delete();
        functions.logger.log('User removed from Typesense', userId);
    } catch (error) {
        let errorTimestamp = new Date().toUTCString(); // Getting UTC timestamp

        console.error(`Error removing user from Typesense ${userId} at ${errorTimestamp}`, error);
        console.error('Document that caused the error:', documentString);
    }
}

async function updateTypesenseUser(user) {
    const userId = user.uid;
    const name = user.firstName + " " + user.lastName;

    let document = {
        'id': userId,
        'name': name
    }

    try {
        await typesense.releaseClient.collections('users').documents().update(document)
        functions.logger.log('User is beeing updated to Typesense', userId);
    } catch (error) {
        let documentString = JSON.stringify(document);
        let errorTimestamp = new Date().toUTCString(); // Getting UTC timestamp

        console.error(`Error updating user to Typesense ${userId} at ${errorTimestamp}`, error);
        console.error('Document that caused the error:', documentString);
    }
}
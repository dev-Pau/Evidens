const functions = require('firebase-functions');
const admin = require('firebase-admin');
const typesense = require('../../client-typesense');

/*
---------------------
enum UserPhase: Int, Codable {
   case category, details, identity, pending, review, verified, deactivate, ban, deleted
}
---------------------
*/

exports.firestoreUsersOnUpdate = functions.firestore.document('users/{userId}').onUpdate(async (change, context) => {
    const newUser = change.after.data();
    const previousUser = change.before.data();

    const userId = context.params.userId;

    if (newUser.phase === 5 && previousUser.phase !== 5) {
        // User gets verified; Add User to Typesense
        const name = newUser.firstName + " " + newUser.lastName
        const discipline = newUser.discipline

        // If user was previusly deacativated or banned, update his/her cases to visible
        if (previousUser.phase === 6 || previousUser.phase === 7) {
            updateCaseVisibility(0, userId)
            updatePostVisibility(0, userId)
        }
 
        document = { userId, name, discipline }
        console.log('User added to Typesense', userId);
        // TODO: Add user from Typesense
        //return typesense.debugClient.collections('users').documents().create(document)

    } else if (newUser.phase === 6) {
        // User deactivate his/her account;
        console.log('User account has been deactivated', userId);
        // Update cases and posts to hidden
        updateCaseVisibility(4, userId)
        updatePostVisibility(2, userId)
        // TODO: Remove user from Typesense
        
        //console.log('User removed from Typesense', userId);
        //return typesense.debugClient.collections('users').documents(userId).delete()
    } else if (newUser.phase === 7) {
        // User gets banned; Remove user from Typesense and updateCaseVisibility as well
        console.log('User account has been banned by Evidens', userId);
        updateCaseVisibility(4, userId)
        updatePostVisibility(2, userId)

        // TODO: Remove user from Typesense
    } else if (newUser.phase === 8) {
        // TODO: Remove all the user information
        console.log('User deleted after 30 days of deactivation', userId);

    } else if (newUser.phase === 5) {
        // User is; and was verified; Update his/her values from Typesense
        const name = newUser.firstName + " " + newUser.lastName
        document = { userId, name }
        console.log('User updated from Typesense', userId);
        return typesense.debugClient.collections('users').documents(userId).update(document)
    }
});

async function updateCaseVisibility(visible, userId) {
    // Update the visibility field of all the regular cases from the user to visible

    const casesRef = admin.database().ref(`users/${userId}/profile/cases`);

    casesRef.once('value')
        .then(snapshot => {
            const updates = [];
            snapshot.forEach(childSnapshot => {
                const caseId = childSnapshot.key;
                const caseDocRef = admin.firestore().collection('cases').doc(caseId);
                updates.push(caseDocRef.update({ visible: visible }));
            });
            return Promise.all(updates);
        })
        .then(() => {
            console.log('All updates successful');
        })
        .catch(error => {
            console.error('Error updating cases:', error);
        });
}


async function updatePostVisibility(visible, userId) {
    // Update the visibility field of all the regular posts from the user to visible

    const postRef = admin.database().ref(`users/${userId}/profile/posts`);

    postRef.once('value')
        .then(snapshot => {
            const updates = [];
            snapshot.forEach(childSnapshot => {
                const postId = childSnapshot.key;
                const postDocRef = admin.firestore().collection('posts').doc(postId);
                updates.push(postDocRef.update({ visible: visible }));
            });
            return Promise.all(updates);
        })
        .then(() => {
            console.log('All updates successful');
        })
        .catch(error => {
            console.error('Error updating cases:', error);
        });
}



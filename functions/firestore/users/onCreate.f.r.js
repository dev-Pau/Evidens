const functions = require('firebase-functions');
const admin = require('firebase-admin');

/*
  ******************************************
  *                                        *
  *                RELEASE                 *
  *            !!  CAUTION !!              *
  ******************************************
*/

exports.releaseFirestoreUsersOnCreate = functions.firestore.document('users/{userId}').onCreate(async (snapshot, context) => {

    const userId = context.params.userId;

    addPreferences(userId);
    addToDatabase(userId);
});

/*
  ******************************************
  *                                        *
  *                RELEASE                 *
  *            !!  CAUTION !!              *
  ******************************************
*/

async function addPreferences(userId) {

    const preferences = {
        enabled: false,
        reply: {
            value: true,
            replyTarget: 0,
        },
        like: {
            value: true,
            likeTarget: 0,
        },
        connection: true,
        trackCase: false
    };

    try {
        const preferencesRef = admin.firestore().collection('notifications').doc(userId);
        await preferencesRef.set(preferences);
        console.log('Preferences added to User', userId);
    } catch (error) {
        console.error('Error creating notification preferences:', error);
    }
};

/*
  ******************************************
  *                                        *
  *                RELEASE                 *
  *            !!  CAUTION !!              *
  ******************************************
*/

async function addToDatabase(userId) {

    const database = admin.database();

    try {
        const ref = database.ref("users").child(userId);
        await ref.set({ uid: userId });
        console.log('User added to Database', userId);
    } catch(error) {
        console.error("Error writing user to database:", error);
    }
};

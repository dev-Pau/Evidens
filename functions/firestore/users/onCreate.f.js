const functions = require('firebase-functions');
const admin = require('firebase-admin');

exports.firestoreUsersOnCreate = functions.region('europe-west1').firestore.document('users/{userId}').onCreate(async (snapshot, context) => {
    const userId = context.params.userId;

    const addPreferencesPromise = addPreferences(userId);
    const addToDatabasePromise = addToDatabase(userId);

    // Wait for both promises to resolve
    await Promise.all([addPreferencesPromise, addToDatabasePromise]);

    console.log('All operations completed successfully for user', userId);
});

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
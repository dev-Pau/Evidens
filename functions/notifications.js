const functions = require('firebase-functions');
const admin = require('firebase-admin');

const db = admin.firestore();


// Function to remove a feed reference for a specific post
async function removeNotificationsforPost(postId, userId) {
    // Delete notifications for the post
    const notificationsRef = admin.firestore().collection(`notifications/${userId}/user-notifications`);
    const querySnapshot = await notificationsRef.where('contentId', '==', postId).get();
    
    const deletePromises = [];
        querySnapshot.forEach((doc) => {
            const deletePromise = doc.ref.delete();
            deletePromises.push(deletePromise);
        });

        await Promise.all(deletePromises);
};

module.exports = {
    removeNotificationsforPost
};

// Function to remove a feed reference for a specific case
async function removeNotificationsForCase(caseId, userId) {
    const notificationsRef = admin.firestore().collection(`notifications/${userId}/user-notifications`);
    const querySnapshot = await notificationsRef.where('contentId', '==', caseId).get();

    const deletePromises = [];
        querySnapshot.forEach((doc) => {
            const deletePromise = doc.ref.delete();
            deletePromises.push(deletePromise);
        });

        await Promise.all(deletePromises);
};


module.exports = {
    removeNotificationsForCase
};

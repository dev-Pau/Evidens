const functions = require('firebase-functions');
const admin = require('firebase-admin');
const storage = admin.storage();

exports.authOnDelete = functions.auth.user().onDelete(async (user) => {
    const userId = user.uid;

    try {
        removeStorageImages(userId, 'users');
        removeUserData(userId);
        removeUserHistory(userId);
        removeUserDocument(userId);

        return null;
    } catch (error) {
        console.error(`Error deleting user data for UID ${uid} from Realtime Database:`, error);
        throw error;
    }
});


async function removeStorageImages(userId, folderPath) {

    const bucket = storage.bucket();
    try {
        // List all files within the folder
        const [files] = await bucket.getFiles({ prefix: `${folderPath}/${userId}/` });

        // Delete each file
        await Promise.all(files.map(file => file.delete()));

        // Delete the folder itself
        await bucket.deleteFiles({ prefix: `${folderPath}/${userId}/` });

        console.log(`All files in ${folderPath}/${userId}/ have been deleted.`);
    } catch (error) {
        console.error('Error removing storage folder contents:', error);
    }
}

async function removeUserData(userId) {
    await admin.database().ref(`users/${userId}`).remove();
    console.log(`User data for UID ${userId} successfully deleted from Realtime Database.`);
}

async function removeUserHistory(userId) {
    const historyRef = admin.firestore().collection(`history/${userId}/phase`);

    const snapshot = await historyRef.get();

    const batch = admin.firestore().batch();
    snapshot.forEach((doc) => {
        batch.delete(doc.ref);
    });

    await batch.commit();
    console.log(`History for user ${userId} successfully removed from Firestore.`);
}

async function removeUserDocument(userId) {
    const userRef = admin.firestore().collection('users').doc(userId);
    
    try {
        await userRef.update({
            email: admin.firestore.FieldValue.delete(),
            firstName: admin.firestore.FieldValue.delete(),
            kind: admin.firestore.FieldValue.delete(),
            lastName: admin.firestore.FieldValue.delete(),
            imageUrl: admin.firestore.FieldValue.delete(),
            bannerUrl: admin.firestore.FieldValue.delete()
        });

        console.log(`Document for user ${userId} successfully updated from Firestore.`);
    } catch (error) {
        console.error(`Error updating user document for user ${userId}:`, error);
    }
}

async function removeUserNotifications(userId) {
    const notificationRef = admin.firestore().collection('notifications').doc(userId).collection('user-notifications');
    const snapshot = await notificationRef.get();

    const deletePromises = [];
    snapshot.forEach(doc => {
        deletePromises.push(doc.ref.delete());
    });

    await Promise.all(deletePromises);

    const userRef = admin.firestore().collection('notifications').doc(userId);
    userRef.delete();

    console.log('Notifications deleted successfully');
}
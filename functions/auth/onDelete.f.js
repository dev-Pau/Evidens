const functions = require('firebase-functions');
const admin = require('firebase-admin');
const storage = admin.storage();

exports.authOnDelete = functions.auth.user().onDelete(async (user) => {
    const userId = user.uid;

    try {
        console.log(`Attempting deleting user data for UID ${userId}`, error);
        removeStorageImages(userId, 'users');
        removeUserData(userId);
        removeUserHistory(userId);
        removeUserDocument(userId);
        removeConnections(userId);
        removeUsername(userId);

        removeFollowing(userId);
        removeFollowers(userId);
        return null;
    } catch (error) {
        console.error(`Error deleting user data for UID ${userId}`, error);
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
            username: admin.firestore.FieldValue.delete(),
            bannerUrl: admin.firestore.FieldValue.delete()
        });

        console.log(`Document for user ${userId} successfully updated from Firestore.`);
    } catch (error) {
        console.error(`Error updating user document for user ${userId}:`, error);
    }
}

async function removeUsername(userId) {
    const usernameRef = admin.firestore().collection('usernames').doc(userId);

    try {
        await usernameRef.delete();
        console.log(`Username for ${userId} successfully deleted from Firestore.`);
    } catch (error) {
        console.error(`Error deleting username ${userId}:`, error);
    }
}

async function removeConnections(userId) {
    const connectionsRef = admin.firestore().collection('connections').doc(userId).collection('user-connections');

    try {
        const connections = await connectionsRef.get();

        const deletionPromises = [];
    
        connections.forEach(doc => {
            const targetUserId = doc.id;
            const userRef = admin.firestore().collection('connections').doc(targetUserId).collection('user-connections');
    
            const deletePromise = userRef.doc(userId).delete();
            deletionPromises.push(deletePromise);
    
            deletionPromises.push(doc.ref.delete());
            
        });
    
        await Promise.all(deletionPromises);
        console.log(`Connections for user ${userId} successfully removed.`);
    } catch (error) {
        console.error(`Error removing connections for user ${userId}.`, error);  
    }
}

async function removeFollowers(userId) {
    const followersRef = admin.firestore().collection('followers').doc(userId).collection('user-followers');

    try {
        const followers = await followersRef.get();

        const deletionPromises = [];

        followers.forEach(doc => {
            const targetUserId = doc.id;
            const userRef = admin.firestore().collection('following').doc(targetUserId).collection('user-following');

            const deletePromise = userRef.doc(userId).delete();
            deletionPromises.push(deletePromise);

            deletionPromises.push(doc.ref.delete());

        });
        await Promise.all(deletionPromises);
        console.log(`Followers for user ${userId} successfully removed.`);
    } catch (error) {
        console.error(`Error removing followers for user ${userId}.`, error);  
    }
}

async function removeFollowing(userId) {
    const followingRef = admin.firestore().collection('following').doc(userId).collection('user-following');

    try {
        const followings = await followingRef.get();

        const deletionPromises = [];

        followings.forEach(doc => {
            const targetUserId = doc.id;
            const userRef = admin.firestore().collection('followers').doc(targetUserId).collection('user-followers');

            const deletePromise = userRef.doc(userId).delete();
            deletionPromises.push(deletePromise);

            deletionPromises.push(doc.ref.delete());
        });

        await Promise.all(deletionPromises);
        console.log(`Following for user ${userId} successfully removed.`);
    } catch (error) {
        console.error(`Error removing following for user ${userId}.`, error);  
    }
}

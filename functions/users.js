const functions = require('firebase-functions');
const admin = require('firebase-admin');

const db = admin.firestore();

// Function to remove a feed reference for a specific post
async function removePostFromFeed(postId, userId) {
    const followersRef = admin.firestore().collection(`followers/${userId}/user-followers`);
    const followersSnapshot = await followersRef.get();
  
    const deletePromises = [];
    followersSnapshot.forEach((doc) => {
      const userId = doc.id;
      const userHomeFeedRef = admin.firestore().collection(`users/${userId}/user-home-feed`);
      const deletePromise = userHomeFeedRef.doc(postId).delete();
      deletePromises.push(deletePromise);
    });

    // Also remove the post from the owner's home feed
    const ownerHomeFeedRef = admin.firestore().collection(`users/${userId}/user-home-feed`);
    const deleteOwnerPromise = ownerHomeFeedRef.doc(postId).delete();
    deletePromises.push(deleteOwnerPromise);
  
    await Promise.all(deletePromises);
};

module.exports = {
  removePostFromFeed
};

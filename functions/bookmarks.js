const functions = require('firebase-functions');
const admin = require('firebase-admin');

const db = admin.firestore();

// Function to remove bookmarks for a specific post
async function removeBookmarksForPost(postId) {
    const postBookmarksRef = admin.firestore().collection(`posts/${postId}/post-bookmarks`);
    const postBookmarksSnapshot = await postBookmarksRef.get();
  
    const deletePromises = [];
    postBookmarksSnapshot.forEach((doc) => {
      const userId = doc.id;
      const userPostsBookmarksRef = admin.firestore().collection(`users/${userId}/user-post-bookmarks`);
      const deletePromise = userPostsBookmarksRef.doc(postId).delete();
      deletePromises.push(deletePromise);
    });
  
    await Promise.all(deletePromises);
};

module.exports = {
  removeBookmarksForPost
};
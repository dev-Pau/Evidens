const functions = require('firebase-functions');
const admin = require('firebase-admin');

const db = admin.firestore();

// Remove bookmarks for a specific post
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

async function removeBookmarksForCase(caseId) {
  const caseBookmarksRef = admin.firestore().collection(`cases/${caseId}/case-bookmarks`);
  const caseBookmarksSnapshot = await caseBookmarksRef.get();

  const deletePromises = [];
  caseBookmarksSnapshot.forEach((doc) => {
    const userId = doc.id;
    const userCasesBookmarksRef = admin.firestore().collection(`users/${userId}/user-case-bookmarks`);
    const deletePromise = userCasesBookmarksRef.doc(caseId).delete();
    deletePromises.push(deletePromise);
  });

  await Promise.all(deletePromises);
};

module.exports = {
  removeBookmarksForPost,
  removeBookmarksForCase
};


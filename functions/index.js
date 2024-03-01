const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();
const { object } = require('firebase-functions/v1/storage');
const { firestore } = require('firebase-admin');

/*
    **** AUTH ****
*/

const { authOnDelete } = require('./auth/onDelete.f')
const { releaseAuthOnDelete } = require('./auth/onDelete.f.r')

/*
    **** USERS ****
*/

const { firestoreUsersOnCreate } = require('./firestore/users/onCreate.f');
const { releaseFirestoreUsersOnCreate } = require('./firestore/users/onCreate.f.r');

const { firestoreUsersOnUpdate } = require('./firestore/users/onUpdate.f');
const { releaseFirestoreUsersOnUpdate } = require('./firestore/users/onUpdate.f.r');

/*
    **** POSTS ****
*/

const { firestorePostsOnCreate } = require('./firestore/posts/onCreate.f');
const { releaseFirestorePostsOnCreate } = require('./firestore/posts/onCreate.f.r');

const { firestorePostsOnUpdate } = require('./firestore/posts/onUpdate.f');
const { releaseFirestorePostsOnUpdate } = require('./firestore/posts/onUpdate.f.r');

const { firestoreLikesPostsOnCreate, firestoreLikesPostsCommentsOnCreate } = require('./firestore/likes/posts/onCreate.f');
const { releaseFirestoreLikesPostsOnCreate, releaseFirestoreLikesPostsCommentsOnCreate } = require('./firestore/likes/posts/onCreate.f.r');

/*
    **** CASES ****
*/

const { firestoreCasesOnCreate } = require('./firestore/cases/onCreate.f');
const { releaseFirestoreCasesOnCreate } = require('./firestore/cases/onCreate.f.r');

const { firestoreCasesOnUpdate } = require('./firestore/cases/onUpdate.f');
const { releaseFirestoreCasesOnUpdate } = require('./firestore/cases/onUpdate.f.r');

const { firestoreLikesCasesOnCreate, firestoreLikesCasesCommentOnCreate } = require('./firestore/likes/cases/onCreate.f');
const { releaseFirestoreLikesCasesOnCreate, releaseFirestoreLikesCasesCommentOnCreate } = require('./firestore/likes/cases/onCreate.f.r');

/*
    **** COMMENTS ****
*/

const { firestoreCommentsCasesOnCreate } = require('./firestore/comments/cases/onCreate.f');
const { releaseFirestoreCommentsCasesOnCreate } = require('./firestore/comments/cases/onCreate.f.r');

const { firestoreCommentsPostsOnCreate } = require('./firestore/comments/posts/onCreate.f');
const { releaseFirestoreCommentsPostsOnCreate } = require('./firestore/comments/posts/onCreate.f.r');

/*
   **** CONNECTIONS ****
*/

const { firestoreConnectionsOnCreate } = require('./firestore/connections/onCreate.f');
const { releaseFirestoreConnectionsOnCreate } = require('./firestore/connections/onCreate.f.r');
/*
   **** FOLLOWERS ****
*/

const { firestoreFollowersOnCreate } = require('./firestore/followers/onCreate.f');
const { releaseFirestoreFollowersOnCreate } = require('./firestore/followers/onCreate.f.r');

/*
    **** FOLLOWING ****
*/

const { firestoreFollowingOnDelete } = require('./firestore/following/onDelete.f');
const { releaseFirestoreFollowingOnDelete } = require('./firestore/following/onDelete.f.r');

/*
    **** REVISION ****
*/

const { firestoreRevisionsOnCreate } = require('./firestore/revisions/onCreate.f');
const { releaseFirestoreRevisionsOnCreate } = require('./firestore/revisions/onCreate.f.r');

/*
    **** HTTPS ****
*/
const { httpsConnectionsOnCallAcceptConnection } = require('./https/connections/onCall.f');
const { releaseHttpsConnectionsOnCallAcceptConnection } = require('./https/connections/onCall.f.r');

const { httpsLikesCasesCommentOnCall } = require('./https/likes/cases/onCall.f');
const { releaseHttpsLikesCasesCommentOnCall } = require('./https/likes/cases/onCall.f.r');

const { httpsLikesPostsCommentOnCall } = require('./https/likes/posts/onCall.f');
const { releaseHttpsLikesPostsCommentOnCall } = require('./https/likes/posts/onCall.f.r');

const { httpsCommentsPostsOnCall } = require('./https/comments/posts/onCall.f');
const { releaseHttpsCommentsPostsOnCall } = require('./https/comments/posts/onCall.f.r');

const { httpsCommentsCasesOnCall } = require('./https/comments/cases/onCall.f');
const { releaseHttpsCommentsCasesOnCall } = require('./https/comments/cases/onCall.f.r');


exports.authOnDelete = authOnDelete;
exports.releaseAuthOnDelete = releaseAuthOnDelete;

exports.firestoreUsersOnCreate = firestoreUsersOnCreate;
exports.releaseFirestoreUsersOnCreate = releaseFirestoreUsersOnCreate;

exports.firestoreUsersOnUpdate = firestoreUsersOnUpdate;
exports.releaseFirestoreUsersOnUpdate = releaseFirestoreUsersOnUpdate;


exports.firestorePostsOnCreate = firestorePostsOnCreate;
exports.releaseFirestorePostsOnCreate = releaseFirestorePostsOnCreate;

exports.firestorePostsOnUpdate = firestorePostsOnUpdate;
exports.releaseFirestorePostsOnUpdate = releaseFirestorePostsOnUpdate;



exports.firestoreLikesPostsOnCreate = firestoreLikesPostsOnCreate;
exports.releaseFirestoreLikesPostsOnCreate = releaseFirestoreLikesPostsOnCreate;

exports.firestoreLikesPostsCommentsOnCreate = firestoreLikesPostsCommentsOnCreate;
exports.releaseFirestoreLikesPostsCommentsOnCreate = releaseFirestoreLikesPostsCommentsOnCreate;

exports.firestoreCasesOnCreate  = firestoreCasesOnCreate;
exports.releaseFirestoreCasesOnCreate = releaseFirestoreCasesOnCreate;

exports.firestoreCasesOnUpdate = firestoreCasesOnUpdate;
exports.releaseFirestoreCasesOnUpdate = releaseFirestoreCasesOnUpdate;

exports.firestoreCommentsCasesOnCreate = firestoreCommentsCasesOnCreate;
exports.releaseFirestoreCommentsCasesOnCreate = releaseFirestoreCommentsCasesOnCreate;

exports.firestoreCommentsPostsOnCreate = firestoreCommentsPostsOnCreate;
exports.releaseFirestoreCommentsPostsOnCreate = releaseFirestoreCommentsPostsOnCreate;



exports.firestoreFollowersOnCreate = firestoreFollowersOnCreate;
exports.releaseFirestoreFollowersOnCreate = releaseFirestoreFollowersOnCreate;

exports.firestoreFollowingOnDelete = firestoreFollowingOnDelete;
exports.releaseFirestoreFollowingOnDelete = releaseFirestoreFollowingOnDelete;

exports.firestoreRevisionsOnCreate = firestoreRevisionsOnCreate;
exports.releaseFirestoreRevisionsOnCreate = releaseFirestoreRevisionsOnCreate;

exports.firestoreLikesCasesOnCreate = firestoreLikesCasesOnCreate;
exports.releaseFirestoreLikesCasesOnCreate = releaseFirestoreLikesCasesOnCreate;

exports.firestoreLikesCasesCommentOnCreate = firestoreLikesCasesCommentOnCreate;
exports.releaseFirestoreLikesCasesCommentOnCreate = releaseFirestoreLikesCasesCommentOnCreate;


exports.firestoreConnectionsOnCreate = firestoreConnectionsOnCreate;
exports.releaseFirestoreConnectionsOnCreate = releaseFirestoreConnectionsOnCreate;


exports.httpsConnectionsOnCallAcceptConnection = httpsConnectionsOnCallAcceptConnection;
exports.releaseHttpsConnectionsOnCallAcceptConnection = releaseHttpsConnectionsOnCallAcceptConnection;

exports.httpsLikesCasesCommentOnCall = httpsLikesCasesCommentOnCall;
exports.releaseHttpsLikesCasesCommentOnCall = releaseHttpsLikesCasesCommentOnCall;

exports.httpsLikesPostsCommentOnCall = httpsLikesPostsCommentOnCall;
exports.releaseHttpsLikesPostsCommentOnCall = releaseHttpsLikesPostsCommentOnCall;

exports.httpsCommentsPostsOnCall = httpsCommentsPostsOnCall;
exports.releaseHttpsCommentsPostsOnCall = releaseHttpsCommentsPostsOnCall;

exports.httpsCommentsCasesOnCall = httpsCommentsCasesOnCall;
exports.releaseHttpsCommentsCasesOnCall = releaseHttpsCommentsCasesOnCall;
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const client = require('./config');

admin.initializeApp();

const db = admin.firestore();
const { object } = require('firebase-functions/v1/storage');
const { firestore } = require('firebase-admin');

const { firestoreUsersOnCreate } = require('./firestore/users/onCreate.f');
const { firestoreUsersOnUpdate } = require('./firestore/users/onUpdate.f');

const { firestorePostsOnCreate } = require('./firestore/posts/onCreate.f');
const { firestorePostsOnUpdate } = require('./firestore/posts/onUpdate.f');

const { firestoreLikesPostsOnCreate, firestoreLikesPostsCommentsOnCreate } = require('./firestore/likes/posts/onCreate.f');

const { firestoreCasesOnCreate } = require('./firestore/cases/onCreate.f');
const { firestoreCasesOnUpdate } =  require('./firestore/cases/onUpdate.f');

const { firestoreCommentsCasesOnCreate } = require('./firestore/comments/cases/onCreate.f');

const { firestoreCommentsPostsOnCreate } = require('./firestore/comments/posts/onCreate.f');

const { firestoreLikesCasesOnCreate, firestoreLikesCasesCommentOnCreate } = require('./firestore/likes/cases/onCreate.f');

const { firestoreConnectionsOnCreate } = require('./firestore/connections/onCreate.f');

const { firestoreFollowersOnCreate } = require('./firestore/followers/onCreate.f');

const { httpsConnectionsOnCallAcceptConnection } = require('./https/connections/onCall.f');

const { httpsLikesCasesCommentOnCall } = require('./https/likes/cases/onCall.f');

const { httpsLikesPostsCommentOnCall } = require('./https/likes/posts/onCall.f');

const { httpsCommentsPostsOnCall } = require('./https/comments/posts/onCall.f');

const { httpsCommentsCasesOnCall } = require('./https/comments/cases/onCall.f');

exports.firestoreUsersOnCreate = firestoreUsersOnCreate;
exports.firestoreUsersOnUpdate = firestoreUsersOnUpdate;

exports.firestorePostsOnCreate = firestorePostsOnCreate;
exports.firestorePostsOnUpdate = firestorePostsOnUpdate;

exports.firestoreLikesPostsOnCreate = firestoreLikesPostsOnCreate;
exports.firestoreLikesPostsCommentsOnCreate = firestoreLikesPostsCommentsOnCreate;

exports.firestoreCasesOnCreate  = firestoreCasesOnCreate;
exports.firestoreCasesOnUpdate = firestoreCasesOnUpdate;

exports.firestoreCommentsCasesOnCreate = firestoreCommentsCasesOnCreate;

exports.firestoreCommentsPostsOnCreate = firestoreCommentsPostsOnCreate;

exports.firestoreFollowersOnCreate = firestoreFollowersOnCreate;

exports.firestoreLikesCasesOnCreate = firestoreLikesCasesOnCreate;
exports.firestoreLikesCasesCommentOnCreate = firestoreLikesCasesCommentOnCreate;

exports.firestoreConnectionsOnCreate = firestoreConnectionsOnCreate;

exports.httpsConnectionsOnCallAcceptConnection = httpsConnectionsOnCallAcceptConnection;

exports.httpsLikesCasesCommentOnCall = httpsLikesCasesCommentOnCall;

exports.httpsLikesPostsCommentOnCall = httpsLikesPostsCommentOnCall;

exports.httpsCommentsPostsOnCall = httpsCommentsPostsOnCall;

exports.httpsCommentsCasesOnCall = httpsCommentsCasesOnCall;



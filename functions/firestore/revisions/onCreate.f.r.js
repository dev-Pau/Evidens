const functions = require('firebase-functions');
const admin = require('firebase-admin');
const db = admin.firestore();

/*
  ******************************************
  *                                        *
  *                RELEASE                 *
  *            !!  CAUTION !!              *
  *                                        *
  ******************************************
*/


exports.releaseFirestoreRevisionsOnCreate = functions.region('europe-west1').firestore.document('cases/{caseId}/case-revisions/{revisionId}').onCreate(async (snapshot, context) => {
    const caseId = context.params.caseId;
    const revisionId = context.params.revisionId;

    const revisionData = snapshot.data();

    const content = revisionData.content;
    const kind = revisionData.kind;
    const timestamp = revisionData.timestamp;
    const title = revisionData.title;

    const bookmarksRef = db.collection('cases').doc(caseId).collection('case-bookmarks');
    const bookmarksSnapshot = await bookmarksRef.get();

    const userIds = bookmarksSnapshot.docs.map(doc => doc.id);

    if (userIds.length === 0) {
        console.log('Case has no bookmarks.', caseId);
        return null;
    }

    // Get the case information, userId and privacy

    const caseRef = db.collection('cases').doc(caseId);
    const caseSnapshot = await caseRef.get()

    const userId = caseSnapshot.data().uid;
    const privacy = caseSnapshot.data().privacy;

    // Remove the userId from userIds array; reason: prevent sending a notification to the owner
    const filteredUserIds = userIds.filter(id => id !== userId);

    if (filteredUserIds.length === 0) {
        console.log('Case has no bookmarks other than the owner.', caseId);
        return null;
    }

    const notificationData = {
        path: [revisionId],
        contentId: caseId,
        timestamp: timestamp,
    };

    if (privacy === 0) {
        notificationData.uid = userId;
    }

    if (kind === 1) {
        // Revision
        notificationData.kind = 221;
    } else if (kind === 2) {
        // Diagnosis
        notificationData.kind = 231;
    } else {
        console.log('Something bad happened.', caseId);
        return null;
    }

    filteredUserIds.forEach(async (filteredUserId) => {
        const userNotificationsRef = admin
        .firestore()
        .collection('notifications')
        .doc(filteredUserId)
        .collection('user-notifications');

        const notificationRef = await userNotificationsRef.add(notificationData);
        const notificationId = notificationRef.id;

        await notificationRef.update({ id: notificationId });
    });
});

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const db = admin.firestore();
const typesense = require('../../client-typesense');

/*
  ******************************************
  *                                        *
  *                RELEASE                 *
  *            !!  CAUTION !!              *
  *                                        *
  ******************************************
*/


exports.releaseFirestoreCasesOnUpdate = functions.firestore.document('cases/{caseId}').onUpdate(async (change, context) => {

    const newValue = change.after.data();
    const previousValue = change.before.data();

    const caseId = context.params.caseId;
    const userId = newValue.uid;

    // If the case gets deleted, beeing visible, pending or approved
    if (newValue.visible === 1 && previousValue.visible !== 1) {

        functions.logger.log('Case has been deleted by the user', userId, caseId);
        deleteNotificationsForCase(caseId, userId);
        return typesense.debugClient.collections('cases').documents(caseId).delete()

    } else {

        // If the case becomes visible, it has been approved by Evidens
        if (newValue.visible === 0 && previousValue.visible !== 0) {

            functions.logger.log('Case has been accepted by Evidens', caseId);

            const privacy = newValue.privacy
            const timestamp = admin.firestore.FieldValue.serverTimestamp();

            const timestampData = {
                timestamp: timestamp
            };

            const caseRef = db.collection('cases').doc(caseId);
            await caseRef.update(timestampData);

            // If the case is not anonymous
            if (privacy === 0) {
                const timestampInSeconds = Math.floor(Date.now() / 1000);

                const timestampSeconds = {
                    timestamp: timestampInSeconds
                };

                const userRef = admin.database().ref(`users/${userId}/profile/cases/${caseId}`);
                userRef.set(timestampSeconds);
                functions.logger.log('Case not anonymous, reference to user profile added', caseId);

            } else {
                functions.logger.log('Case is anonymous', caseId);
            }

            //Delete the reference of the case in the drafts of the user
            const draftRef = admin.database().ref(`users/${userId}/drafts/cases/${caseId}`);
            draftRef.remove();
            functions.logger.log('Case removed from drafts reference', caseId);

            //Send Notification to the user that the case has been accepted.
            addNotificationOnCaseApprove(caseId, userId);

            //TODO: Add Case to Typesense
            //TODO: Send Push Notification

            // The case changes to pending, meaning the user has to perform some changes
        } else if (newValue.visible === 2 && previousValue.visible !== 2) {
            functions.logger.log('Case has to be reviewed by the user due to some problem', caseId);
            // The case changes to needs to approve state, meaning Evidens has to approve the case
        } else if (newValue.visible === 3 && previousValue.visible !== 3) {
            functions.logger.log('Case has to be approved by Evidens after a revision', caseId);
        }
    }

    return null;
});


async function addNotificationOnCaseApprove(caseId, userId) {

    const timestamp = admin.firestore.FieldValue.serverTimestamp();

    const notificationData = {
        contentId: caseId,
        kind: 201,
        timestamp: timestamp,
        uid: userId,
    };

    const userNotificationsRef = admin
        .firestore()
        .collection('notifications')
        .doc(userId)
        .collection('user-notifications');

    const notificationRef = await userNotificationsRef.add(notificationData);
    const notificationId = notificationRef.id;

    await notificationRef.update({ id: notificationId });
}

async function deleteNotificationsForCase(caseId, userId) {
    const notificationsRef = admin.firestore().collection(`notifications/${userId}/user-notifications`);
    const querySnapshot = await notificationsRef.where('contentId', '==', caseId).get();

    const deletePromises = [];
    querySnapshot.forEach((doc) => {
        const deletePromise = doc.ref.delete();
        deletePromises.push(deletePromise);
    });

    await Promise.all(deletePromises);
    console.log('Notifications for the case deleted', caseId);
};

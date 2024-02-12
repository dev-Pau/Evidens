const functions = require('firebase-functions');
const admin = require('firebase-admin');
const db = admin.firestore();
const typesense = require('../../client-typesense');

/*
------
TODO:
    - Add Typesense client code to add the case to the database
    - Add Typesense client code to delete the case to the database
    - Add Typesense client code to update the case to the database
    - Add a new case for cases that are pending to be approved, if they get deleted the drafts RTD root should also be deleted
    - When case can be reviewed, at info to last 2 ifs (if case needs changes, and if case needs approve after changes)
    - Need to send a push notification when it has been approved
-----
*/

/*
enum CaseVisibility: Int {
     - Regular: The case is visible and accessible to all users.
     - Deleted: The case has been deleted by the user.
     - Pending: The case is pending approval from Evidens.
     - Approve: The case has been approved by Evidens.
     - Hidden: The case is hidden due to the user's account deactivation or deletion.
     - Disabled: The case has been permanently removed by Evidens.

     case regular, deleted, pending, approve, hidden, disabled
}
*/

exports.firestoreCasesOnUpdate = functions.firestore.document('cases/{caseId}').onUpdate(async (change, context) => {

    const newValue = change.after.data();
    const previousValue = change.before.data();

    const caseId = context.params.caseId;
    const userId = newValue.uid;

    // If the case gets deleted by the user
    if (newValue.visible === 1 && previousValue.visible !== 1) {

        functions.logger.log('Case has been deleted by the user', userId, caseId);
        deleteNotificationsForCase(caseId, userId);
        return typesense.debugClient.collections('cases').documents(caseId).delete()

    } else {
       
        // If the case becomes visible
        if (newValue.visible === 0) {

            //  Case was pending to be approved and it has been approved by Evidens.
            if (previousValue.visible === 3) {
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
    

            } else if (previousValue.visible === 4) {
                // Case was previously hidden Evidens and is now visible again
                functions.logger.log('Case changes to regular from hidden', caseId);

            } else if (previousValue.visible === 5) { 
                // Case was previously banned from Evidens and is now visible again
                functions.logger.log('Case admitted again, add to Typesense', caseId);
                //TODO: Add Case to Realtime (if it wasn't anonymous)
                //TODO: Add Case to Typesense
            }
            // The case changes to pending, meaning the user has to perform some changes
        } else if (newValue.visible === 2 && previousValue.visible !== 2) {
            functions.logger.log('Case has to be reviewed by the user due to some problem', caseId);
            // The case changes to needs to approve state, meaning Evidens has to approve the case
        } else if (newValue.visible === 3 && previousValue.visible !== 3) {
            functions.logger.log('Case has to be approved by Evidens after a revision', caseId);
        } else if (newValue.visible === 4 && previousValue.visible !== 4) {
            // Case is hidden from Evidens, we do nothing
            functions.logger.log('Case has been hidden', caseId);
        } else if (newValue.visible === 5 && previousValue.visible !== 5) {
            // Case is banned from Evidens, remove from Typesense and Realtime
            functions.logger.log('Case has been banned', caseId);
            //TODO: Remove Case from Realtime (if it wasn't anonymous)
            //TODO: Remove Case from Typesense
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

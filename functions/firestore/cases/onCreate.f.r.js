const functions = require('firebase-functions');
const admin = require('firebase-admin');


/*
  ******************************************
  *                                        *
  *                RELEASE                 *
  *            !!  CAUTION !!              *
  *                                        *
  ******************************************
*/

exports.releaseFirestoreCasesOnCreate = functions.region('europe-west1').firestore.document('cases/{caseId}').onCreate(async (snapshot, context) => {
  const caseId = context.params.caseId;
  const userId = snapshot.data().uid;

  const timestampInSeconds = Math.floor(Date.now() / 1000);

  const timestampSeconds = {
    timestamp: timestampInSeconds
  };

  const userRef = admin.database().ref(`users/${userId}/drafts/cases/${caseId}`);

  try {
    await userRef.set(timestampSeconds);
    console.log("New case has been added", caseId);

  } catch (error) {
    console.error(`Error creating case ${caseId}`, error);
  }
});
